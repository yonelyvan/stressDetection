const {Router} = require('express');
const express= require('express')
const multer = require('multer');
const request = require('request');

const path = require('path');

var upload = multer({ dest: 'uploads/' })


const router = Router()

const fs = require('fs');



/// routes test: http://localhost:3000/test
router.get('/test',(req,res) => {
    const data = [
        {
            "id": "1",
            "languaje" : "dart"
        },
        {
            "id": "2",
            "languaje" : "python"
        }
    ];
    res.json(data);
});


  //upload audio from app, files are saved on /uploads
  router.post('/upload', upload.single("file"), function (req,res) {
    console.log("Received file" + req.file.originalname);
    var src = fs.createReadStream(req.file.path);
    var dest = fs.createWriteStream('uploads/' + req.file.originalname);
    src.pipe(dest);
    src.on('end', function() {
    	fs.unlinkSync(req.file.path);
        ///--------------------------
        var currenPath = __dirname;
        var final_path =  path.resolve(__dirname+'../../../');
        var currentPathFile = final_path+'/'+dest.path; 
        console.log(currentPathFile);
        
        var audio_path = currentPathFile;
        // send POST to flask
        request({
            method: 'POST',
            url: 'http://localhost:5000/flask_voice_stress_level',
            json: {"audio_path": audio_path}
        }, (error, response, body) => {
            console.log(error);
            console.log(body);
            res.json(body);
        });
    });

    src.on('error', function(err) { 
      res.json({'result' : -1}); 
    });
  })

module.exports = router;