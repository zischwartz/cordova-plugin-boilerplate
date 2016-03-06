var exec = require('cordova/exec');

exports.begin = function(arg0, success, error) {
    exec(success, error, "SwiftVideo", "begin", [arg0]);
};


exports.setupPalette = function(arg0, success, error) {
    exec(success, error, "SwiftVideo", "setupPalette", [arg0]);
};

exports.setupCamera = function(arg0, success, error) {
    exec(success, error, "SwiftVideo", "setupCamera", [arg0]);
};