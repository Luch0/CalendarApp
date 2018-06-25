module.exports = function(app, db) {

  var ObjectID = require('mongodb').ObjectID;

  // get all events
  app.get('/events/', (req, res) => {
    db.collection('events').find({}).toArray(function(err, result) {
      if (err) {
        res.send({'error':'An error has occurred getting all events'});
      } else {
        res.send(result);
      } 
    });
  });

  // get event by ID
  app.get('/events/:id', (req, res) => {
    const id = req.params.id;
    const details = { '_id': new ObjectID(id) };
    db.collection('events').findOne(details, (err, item) => {
      if (err) {
        res.send({'error':'An error has occurred getting the event'});
      } else {
        res.send(item);
      } 
    });
  });

  // create an event
  app.post('/events', (req, res) => {
    const event = { title: req.body.title, 
                    description: req.body.description, 
                    startTime: parseFloat(req.body.startTime), 
                    endTime: parseFloat(req.body.endTime), 
                    day: parseInt(req.body.day), 
                    month: parseInt(req.body.month), 
                    year: parseInt(req.body.year),
                    startTimeStr: req.body.startTimeStr,
                    endTimeStr: req.body.endTimeStr};
    db.collection('events').insert(event, (err, result) => {
      if (err) { 
        res.send({ 'error': 'An error has occurred saving event'}); 
      } else {
        res.send(result.ops[0]);
      }
    });
  });

  // delete an event
  app.delete('/events/:id', (req, res) => {
    const id = req.params.id;
    const details = { '_id': new ObjectID(id) };
    db.collection('events').remove(details, (err, item) => {
      if (err) {
        res.send({'error':'An error has occurred deleting the event'});
      } else {
        res.send('Event ' + id + ' deleted!');
      } 
    });
  });

  // update an event
  app.put('/events/:id', (req, res) => {
    const id = req.params.id;
    const details = { '_id': new ObjectID(id) };
    const event = { title: req.body.title, 
                    description: req.body.description, 
                    startTime: parseFloat(req.body.startTime), 
                    endTime: parseFloat(req.body.endTime), 
                    day: parseInt(req.body.day), 
                    month: parseInt(req.body.month), 
                    year: parseInt(req.body.year),
                    startTimeStr: req.body.startTimeStr,
                    endTimeStr: req.body.endTimeStr};
    db.collection('events').update(details, event, (err, result) => {
      if (err) {
          res.send({'error':'An error has occurred updating the event'});
      } else {
          res.send(event);
      } 
    });
  });

};