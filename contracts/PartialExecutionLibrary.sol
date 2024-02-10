// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


/**
  @dev Brings basic data structures and functions for partial execution.
  The main data structures are:
    Task: Represents a function that needs to be executed by steps.
    TaskGroup: Represents a group that contains several functions that needs to be executed by steps.
  Tasks and Tasks groups can be executed specifying the amount of steps to run.
  Since this contract is a library, it must receive the mappings where to store/get the Tasks and TaskGroups.
  It is a responsability of the user to consistently pass the same mappings.
*/
library PartialExecutionLibrary {
  using SafeMath for uint256;
  bytes32 constant NULL_TASK = bytes32(0);
  bytes32 constant NULL_GROUP = bytes32(0);

  enum ExecutionState {
    Ready,
    Running,
    Finished
  }

  struct TaskGroup {
    bytes32 id;
    ExecutionState state;
    bytes32[] subTasks;
    function(bytes32) internal onStart;
    function(bytes32) internal onFinish;
    bool autoRestart;
  }

  struct Task {
    bytes32 id;
    function(bytes32, bytes32, uint256) internal returns(bool) stepFunction;
    function(bytes32, bytes32) internal onStart;
    function(bytes32, bytes32) internal onFinish;
    uint256 currentStep;
    ExecutionState state;
  }

  /**
     @dev Creates a task group
     @param _taskGroups mapping where to store the task group
     @param _tasks mapping where to get the substasks from
     @param _id Id of the task group
     @param _subtasksIds Ids of the Tasks to execute when executing the task group
     @param _onStart Function to execute before running the first task
     @param _onFinish Function to execute when all tasks of the group are completed
     @param _autoRestart wether to set everything in the group as ready to run when finishing
       Next execution of the group will NOT start in the same transation that the current one finishes.
   */
  function createTaskGroup(
    mapping (bytes32 => TaskGroup) storage _taskGroups,
    mapping (bytes32 => Task) storage _tasks,
    bytes32 _id,
    bytes32[] memory _subtasksIds,
    function(bytes32) _onStart,
    function(bytes32) _onFinish,
    bool _autoRestart
  ) internal {
    require(_id != NULL_GROUP, "a group cannot have a null id");
    TaskGroup storage group = _taskGroups[_id];
    require(group.id == NULL_GROUP, "a group with that id already exists");
    group.id = _id;
    for (uint256 i = 0; i < _subtasksIds.length; ++i){
      bytes32 taskId = _subtasksIds[i];
      Task storage task = _tasks[taskId];
      require(task.id != NULL_TASK, "one of the specified tasks is invalid");
      group.subTasks.push(taskId);
    }
    group.onStart = _onStart;
    group.onFinish = _onFinish;
    group.state = ExecutionState.Ready;
    group.autoRestart = _autoRestart;
  }

  /**
   @dev Creates a task
   @param _tasks mapping where to save the task
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
    mapping (bytes32 => Task) storage _tasks,
    bytes32 _id,
    function(bytes32, bytes32, uint256) internal returns(bool) _stepFunction,
    function(bytes32, bytes32) internal _onStart,
    function(bytes32, bytes32) internal _onFinish
  ) internal {
    require(_id != NULL_TASK, "a task cannot have a null id");
    Task storage task = _tasks[_id];
    require(task.id == NULL_TASK, "a task with that id already exists");
    task.id = _id;
    task.onStart = _onStart;
    task.onFinish = _onFinish;
    task.state = ExecutionState.Ready;
    task.stepFunction = _stepFunction;
    task.currentStep = 0;
  }

  /**
     @dev Executes all tasks of the group in order using the step count passed as parameter
     @param _taskGroups mapping where to get the group
     @param _tasks mapping where to get the groups' subtasks
     @param _id the group's id
     @param _stepCount Step count to execute
   */
  function executeGroup(
    mapping (bytes32 => TaskGroup) storage _taskGroups,
    mapping (bytes32 => Task) storage _tasks,
    bytes32 _id,
    uint256 _stepCount
  ) internal {
    TaskGroup storage group = _taskGroups[_id];
    require(_stepCount > 0, "it does not make sense to execute a group of tasks with zero steps");
    require(group.id != NULL_GROUP, "the group does not exist");

    if (group.state == ExecutionState.Ready) {
      group.onStart(group.id);
      group.state = ExecutionState.Running;
    }
    // skip everything if the group is finished
    if (group.state == ExecutionState.Running){
      uint256 leftSteps = _stepCount;

      for (uint256 i = 0; leftSteps > 0 && i < group.subTasks.length; i++) {
        Task storage task = _tasks[group.subTasks[i]];
        uint256 consumed = executeTask(task, group.id, leftSteps);
        leftSteps = leftSteps.sub(consumed);
      }

      if (lastTaskCompleted(group, _tasks)) {
        group.state = ExecutionState.Finished;
        group.onFinish(group.id);
        if (group.autoRestart) {
          resetGroup(group, _tasks);
        }
      }
    }
  }

 
  function executeTask(Task storage _self, uint256 steps) internal returns (uint256 stepsConsumed) {
    require(steps > 0, "it does not make sense to execute a task with 0 steps");
    require(_self.id != NULL_TASK, "it is invalid to execute a null task");
    uint256 initialStep = _self.currentStep;

    if (_self.state == ExecutionState.Finished) {
        // No execution
        return 0; // Explicit return statement with value
    }
    if (_self.state == ExecutionState.Ready) {
        _self.onStart(NULL_GROUP, _self.id);
        _self.state = ExecutionState.Running;
    }
    if (_self.state == ExecutionState.Running) {
        uint256 currentStep;
        bool keepGoing = true;
        uint256 endStep = _self.currentStep.add(steps);

        for (currentStep = _self.currentStep; keepGoing && currentStep < endStep; currentStep++) {
            keepGoing = _self.stepFunction(NULL_GROUP, _self.id, currentStep);
        }
        _self.currentStep = currentStep;

        if (!keepGoing) {
            _self.state = ExecutionState.Finished;
            _self.onFinish(NULL_GROUP, _self.id);
        }
    }

    stepsConsumed = _self.currentStep.sub(initialStep); // Assigning value to the return variable
}


  /**
    @dev Set if a Group should be automatically set to Ready state
    after Finnished State is reached
    @param _self the task group
    @param _autoRestart value to set.
  */
  function setAutoRestart(TaskGroup storage _self, bool _autoRestart) internal {
    _self.autoRestart = _autoRestart;
  }

  /**
     @dev Returns true if the group is currently un Running state
     @param _self the task group to execute
     @return boolean
   */
  function isGroupRunning(TaskGroup storage _self) internal view returns(bool) {
    return _self.state == ExecutionState.Running;
  }

  /**
     @dev Returns true if the group is currently in Ready state
     @param _self the task group to execute
     @return boolean
   */
  function isGroupReady(TaskGroup storage _self) internal view returns(bool) {
    return _self.state == ExecutionState.Ready;
  }

  /**
     @dev Returns true if the task is currently un Running state
     @param _self task see if it is running
     @return boolean
   */
  function isTaskRunning(Task storage _self) internal view returns(bool) {
    return _self.state == ExecutionState.Running;
  }

  /**
     @dev Creates a task
     @param _self the task to execute
     @param groupId Id of the group the task runs in
     @param steps Step count to execute
     @return The amount of steps consumed in the execution
   */
  function executeTask(Task storage _self, bytes32 groupId, uint256 steps) private returns(uint256){
    require(steps > 0, "it does not make sense to execute a task with 0 steps");
    // TODO: there are no tests for this.
    require(_self.id != NULL_TASK, "it is invalid to execute a null task");
    uint256 initialStep = _self.currentStep;

    if (_self.state == ExecutionState.Finished) {
      // No execution
      return 0;
    }
    if (_self.state == ExecutionState.Ready) {
      _self.onStart(groupId, _self.id);
      _self.state = ExecutionState.Running;
    }
    if (_self.state == ExecutionState.Running) {
      uint256 currentStep;
      bool keepGoing = true;
      uint256 endStep = _self.currentStep.add(steps);

      for (currentStep = _self.currentStep; keepGoing && currentStep < endStep; currentStep++) {
        keepGoing = _self.stepFunction(groupId, _self.id, currentStep);
      }
      _self.currentStep = currentStep;

      if (!keepGoing) {
        _self.state = ExecutionState.Finished;
        _self.onFinish(groupId, _self.id);
      }
    }

    return _self.currentStep.sub(initialStep);
  }

  /**
     @dev Returns true if the last task of the group was completed
     @param _self the task group to execute
     @param _tasks mapping where to get the group's subtasks.
     @return boolean
   */
  function lastTaskCompleted(
    TaskGroup storage _self,
    mapping (bytes32 => Task) storage _tasks
  ) private view returns(bool){
    Task storage lastTask = _tasks[_self.subTasks[_self.subTasks.length.sub(1)]];

    return lastTask.state == ExecutionState.Finished;
  }

  /**
    @dev Set Group in Ready state. Reset all sub-task.
    @param _self the task group to reset
    @param _tasks the mapping where to get the tasks from
  */
  function resetGroup(
    TaskGroup storage _self,
    mapping (bytes32 => Task) storage _tasks
    ) private {
    _self.state = ExecutionState.Ready;

    resetTasks(_self, _tasks);
  }

  /**
    @dev Reset all tasks in a group. Used at the completion of a task group execution
    @param _self the task group to reset
    @param _tasks the mapping where to get the tasks from
  */
  function resetTasks(TaskGroup storage _self, mapping (bytes32 => Task) storage _tasks) private {
    for (uint256 i = 0; i < _self.subTasks.length; i++) {
      resetTask(_tasks[_self.subTasks[i]]);
    }
  }

  /**
     @dev Put task in Ready to run state and reset currentStep value
     @param _self the task to reset
   */
  function resetTask(Task storage _self) private {
    _self.state = ExecutionState.Ready;
    _self.currentStep = 0;
  }
}