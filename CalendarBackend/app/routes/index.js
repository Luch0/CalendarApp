const eventRoutes = require('./event_routes');
module.exports = function(app, db) {
  eventRoutes(app, db);
};