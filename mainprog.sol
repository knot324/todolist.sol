// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TodoList {

    enum Priority { Low, Medium, High }
    enum Category { Work, Personal, Errands, Other }

    struct Task {
        string description;
        bool completed;
        Priority priority;
        Category category;
        uint256 dueDate;
    }

    mapping(address => Task[]) private userTasks;

    event TaskAdded(address indexed user, uint256 taskId, string description);
    event TaskStatusChanged(address indexed user, uint256 taskId, bool completed);
    event TaskRemoved(address indexed user, uint256 taskId);
    event TaskEdited(address indexed user, uint256 taskId, string newDescription);

    function addTask(
        string memory _description, 
        Priority _priority, 
        Category _category, 
        uint256 _dueDate
    ) public {
        require(bytes(_description).length > 0, "Description cannot be empty");
        
        userTasks[msg.sender].push(Task({
            description: _description,
            completed: false,
            priority: _priority,
            category: _category,
            dueDate: _dueDate
        }));

        emit TaskAdded(msg.sender, userTasks[msg.sender].length - 1, _description);
    }

    function toggleCompleted(uint256 _index) public {
        require(_index < userTasks[msg.sender].length, "Task does not exist");
        Task storage task = userTasks[msg.sender][_index];
        task.completed = !task.completed;

        emit TaskStatusChanged(msg.sender, _index, task.completed);
    }

    function editTask(uint256 _index, string memory _newDescription) public {
        require(_index < userTasks[msg.sender].length, "Task does not exist");
        require(bytes(_newDescription).length > 0, "Description cannot be empty");
        
        userTasks[msg.sender][_index].description = _newDescription;
        emit TaskEdited(msg.sender, _index, _newDescription);
    }

    function removeTask(uint256 _index) public {
        require(_index < userTasks[msg.sender].length, "Task does not exist");

        uint256 lastIndex = userTasks[msg.sender].length - 1;
        
        if (_index != lastIndex) {
            userTasks[msg.sender][_index] = userTasks[msg.sender][lastIndex];
        }
        
        userTasks[msg.sender].pop();

        emit TaskRemoved(msg.sender, _index);
    }

    function getMyTasks() public view returns (Task[] memory) {
        return userTasks[msg.sender];
    }

    function getTasksByStatus(bool _status) public view returns (Task[] memory) {
        Task[] memory allTasks = userTasks[msg.sender];
        uint256 count = 0;

        for (uint256 i = 0; i < allTasks.length; i++) {
            if (allTasks[i].completed == _status) {
                count++;
            }
        }

        Task[] memory filteredTasks = new Task[](count);
        uint256 j = 0;
        for (uint256 i = 0; i < allTasks.length; i++) {
            if (allTasks[i].completed == _status) {
                filteredTasks[j] = allTasks[i];
                j++;
            }
        }
        return filteredTasks;
    }

    function getTaskCount() public view returns (uint256) {
        return userTasks[msg.sender].length;
    }
}