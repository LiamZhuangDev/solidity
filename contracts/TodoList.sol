// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

contract TodoList {
    struct Todo {
        uint id;
        string task;
        bool done;
        uint timestamp;
    }

    uint public constant MAX_TODOS_PER_USER = 100;
    uint private nextId; // auto-increment Id
    mapping(address => uint[]) private userTodoIds; // user => todoId[]
    mapping(uint => Todo) private todos; // todoId => Todo
    mapping(uint => uint) private todoIndex; // todoId => index in userTodoIds[user]
    mapping(uint => address) private todoOwner; // todoId => user

    function addToDo(string memory task) public {
        // check input
        // create Todo instance and assign it to msg.sender
        // attach this todo Id to the index of user's todos
        // increment nextId
        require(bytes(task).length > 0, "Task cannot be empty");
        require(bytes(task).length <= 200, "Task too long");

        uint[] storage ids = userTodoIds[msg.sender];
        require(ids.length < MAX_TODOS_PER_USER, "Todo list is full");
        
        uint id = nextId++;
        ids.push(id);
        todos[id] = Todo({
            id: id,
            task: task,
            done: false,
            timestamp: block.timestamp
        });
        todoIndex[id] = ids.length - 1;
        todoOwner[id] = msg.sender;
    }

    function completeTodo(uint id) external {
        require(todoOwner[id] == msg.sender, "Not owner");

        Todo storage todo = todos[id];
        require(!todo.done, "task already completed");
        todo.done = true;
    }

    function deleteTodo(uint id) external {
        require(todoOwner[id] == msg.sender, "Not owner");

        uint indexToDelete = todoIndex[id];
        uint[] storage ids = userTodoIds[msg.sender];
        uint len = ids.length;
        require(indexToDelete < len, "id out of bounds");
        
        // swap with the last element 
        ids[indexToDelete] = ids[len - 1];

        // pop the last element
        ids.pop();

        delete todos[id];
        delete todoIndex[id];
        delete todoOwner[id];
    }

    function getMyTodos() external view returns (Todo[] memory) {
        uint[] memory ids = userTodoIds[msg.sender];
        uint len = ids.length;
        Todo[] memory myTodos = new Todo[](len);
        for (uint i = 0; i < len; i++) {
            uint id = ids[i];
            myTodos[i] = todos[id];
        }

        return myTodos;
    }

    function getTodo(uint id) external view returns (Todo memory) {
        return todos[id];
    }

    function getMyTodoCount() external view returns (uint count) {
        return userTodoIds[msg.sender].length;
    }
}