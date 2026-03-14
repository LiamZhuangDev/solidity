// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

// Indexed-set pattern:
// 1) a Solidity design that stores items in a mapping by stable ID while 
// 2) keeping an array of those IDs plus an index mapping to enable O(1) lookup, iteration, and deletion.

// Indexed-set pattern with stable IDs And O(1) deletion.
// Indexed-set might be over-engineering for a simple todo list.
contract TodoList {
    struct Todo {
        uint64 timestamp; // slot 0
        bool done; // slot 0
        string task; // slot 1, string always starts a new slot, a pointer to the string
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
            task: task,
            done: false,
            timestamp: uint64(block.timestamp)
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

    function getMyTodos() external view returns (uint[] memory ids, Todo[] memory items) {
        uint[] storage storedIds = userTodoIds[msg.sender];
        uint len = storedIds.length;

        ids = new uint[](len);
        items = new Todo[](len);
        
        for (uint i = 0; i < len; i++) {
            uint id = storedIds[i];
            ids[i] = id;
            items[i] = todos[id];
        }
    }

    function getTodo(uint id) external view returns (Todo memory) {
        require(todoOwner[id] == msg.sender, "Not your todo");
        return todos[id];
    }

    function getMyTodoCount() external view returns (uint count) {
        return userTodoIds[msg.sender].length;
    }
}