var sayHello;

console.log("Hello from one.coffee!");

sayHello("world");

sayHello = function(str) {
  return console.log("Hello " + str + "!");
};
