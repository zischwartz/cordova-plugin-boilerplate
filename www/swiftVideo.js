var exec = require('cordova/exec');

exports.sayHello = function(arg0, success, error) {
    exec(success, error, "SwiftVideo", "sayHello", [arg0]);
};


exports.setupPalette = function(arg0, success, error) {
    exec(success, error, "SwiftVideo", "setupPalette", [arg0]);
};

exports.setupCamera = function(arg0, success, error) {
    exec(success, error, "SwiftVideo", "setupCamera", [arg0]);
};