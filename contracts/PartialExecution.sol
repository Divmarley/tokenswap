// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "./PartialExecutionLibrary.sol";
/**
  @dev wraps the PartialExecutionLibrary to ensure the library is always
  called on the same data.
*/
contract PartialExecution {
  // this is copied from PartialExecutionGroup, since values cant be exported
  mapping (bytes32 => PartialExecutionLibrary.Task) private tasks;
  mapping (bytes32 => PartialExecutionLibrary.TaskGroup) private groups;
  /**
     @dev Creates a task group
     @param _id Id of the task group
     @param _subtasksIds Ids of the Tasks to execute when executing the task group
     @param _onStart Function to execute before running the first task
     @param _onFinish Function to execute when all tasks of the group are completed
     @param _autoRestart wether to set everything in the group as ready to run when finishing
       Next execution of the group will NOT start in the same transation that the current one finishes.
   */
  function createTaskGroup(
    bytes32 _id,
    bytes32[] memory _subtasksIds,
    function(bytes32) _onStart,
    function(bytes32) _onFinish,
    bool _autoRestart
  ) internal {
    PartialExecutionLibrary.createTaskGroup(
      groups,
      tasks,
      _id,
      _subtasksIds,
      _onStart,
      _onFinish,
      _autoRestart
    );
  }

  /**
   @dev Creates a task
   @param _id Id of the task
   Should return the step count of the execution
   @param _stepFunction Function to execute at each step.
     It receives:
       the GroupId to which the task is associated.
         It will be NULL_GROUP if the task is executed outside a group.
       the TaskId which is executing.
       the step number which is executing.
     It MUST return false when there is nothing left to do, true otherwise.
     it MUST gracefully handle being called with an invalid step number.
   @param _onStart Function to execute before task execution
     It receives:
       the GroupId to which the task is associated.
         It will be NULL_GROUP if the task is executed outside a group.
       the TaskId which is executing.
   @param _onFinish Function to execute when all steps are completed
     It receives:
       the GroupId to which the task is associated.
         It will be NULL_GROUP if the task is executed outside a group.
       the TaskId which is executing.
 */
  function createTask(
    bytes32 _id,
    function(bytes32, bytes32, uint256) internal returns(bool) _stepFunction,
    function(bytes32, bytes32) internal _onStart,
    function(bytes32, bytes32) internal _onFinish
  ) internal {
    PartialExecutionLibrary.createTask(
      tasks,
      _id,
      _stepFunction,
      _onStart,
      _onFinish
    );
  }

  /**
     @dev Executes all tasks of the group in order using the step count passed as parameter
     @param _id the group's id
     @param _stepCount Step count to execute
   */
  function executeGroup(
    bytes32 _id,
    uint256 _stepCount
  ) internal {
    PartialExecutionLibrary.executeGroup(groups, tasks, _id, _stepCount);
  }


  function executeTask(bytes32 _id, uint256 steps) internal returns (uint256 stepsConsumed) {
    stepsConsumed = PartialExecutionLibrary.executeTask(tasks[_id], steps);
    return stepsConsumed;
}
  /**
    @dev Set if a Group should be automatically set to Ready state
    after Finished State is reached
    @param _id the task group id
    @param _autoRestart value to set.
  */
  function setAutoRestart(bytes32 _id, bool _autoRestart) internal {
    PartialExecutionLibrary.setAutoRestart(groups[_id], _autoRestart);
  }

 
 
  function isGroupRunning(bytes32 _id) internal view returns (bool groupIsRunning) {
    groupIsRunning = PartialExecutionLibrary.isGroupRunning(groups[_id]);
    return groupIsRunning;
}
 


  function isGroupReady(bytes32 _id) internal view returns (bool groupIsReady) {
    groupIsReady = PartialExecutionLibrary.isGroupReady(groups[_id]);
    return groupIsReady;
}
  
  
  function isTaskRunning(bytes32 _id) internal view returns (bool taskIsRunning) {
    taskIsRunning = PartialExecutionLibrary.isTaskRunning(tasks[_id]);
    return taskIsRunning;
}

  /**
     @dev Auxiliar function for tasks with no on{Finish,Start} function
   */
  function nullHookForTask(bytes32, bytes32) internal {

  }

  /**
     @dev Auxiliar function for groups with no on{Finish,Start} function
   */
  function nullHookForTaskGroup(bytes32) internal {

  }
  // Leave a gap betweeen inherited contracts variables in order to be
  // able to add more variables in them later
  uint256[50] private upgradeGap;
}