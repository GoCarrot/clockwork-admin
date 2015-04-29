'use strict';

var clockworkAdminControllers = angular.module('clockworkAdminControllers', []);

clockworkAdminControllers.controller('EventListCtrl', ['$scope', 'Event', 
  function($scope, Event) {
  $scope.events = Event.query();

  $scope.setPaused = function(event) {
    event.$save();
  };
}]);
