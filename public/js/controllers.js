'use strict';

var clockworkAdminControllers = angular.module('clockworkAdminControllers', []);

clockworkAdminControllers.controller('EventListCtrl', ['$scope', 'Event', 
  function($scope, Event) {
  $scope.events = Event.query();

  $scope.togglePaused = function(event) {
    event.paused = !event.paused;
    event.$save();
  };
}]);
