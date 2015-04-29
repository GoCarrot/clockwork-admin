'use strict';

var clockworkAdminServices = angular.module('clockworkAdminServices', ['ngResource']);

clockworkAdminServices.factory('Event', ['$resource', 
  function($resource) {
    return $resource('events/:id', {id: '@event_name'}, {
            query: {method: 'GET', isArray:true},
            update: {method: 'POST'}
    });
  }]);

