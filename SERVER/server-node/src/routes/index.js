const {Router} = require('express');
const express= require('express')
const multer = require('multer');
const request = require('request');

const path = require('path');

var upload = multer({ dest: 'uploads/' })


const router = Router()

// $ npm install @tensorflow/tfjs-node
const tf = require('@tensorflow/tfjs');

//
const fs = require('fs');


/// IA class
const url = "http://localhost:3000/model.json"
const model =  tf.loadLayersModel(url);
//const model= await tf.loadModel('./json/model.json');


const json_model = require("../model.json")
//const json_model_weigths = require("../group1-shard1of1.bin")

router.get("/model.json",(req,res) => {
    //const model = await tf.loadLayersModel("../models/nn_voice.h5");
    res.json(json_model);
});

router.get("/group1-shard1of1.bin",(req,res) => {
    //res.send("hello");
    ///res.send(json_model_weigths);
    //res.sendFile('group1-shard1of1.bin'}); 
    res.sendFile('group1-shard1of1.bin',  { root : __dirname}); 
});



router.get("/predict",(req,res) => {
    //create a vector
    var v = [[2.44162400e-01, 6.36427390e-01, 6.76160640e-01, 6.65994062e-01,
        7.16701230e-01, 6.12162254e-01, 6.51202345e-01, 5.56460581e-01,
        3.54051135e-01, 5.36721993e-01, 3.73261519e-01, 4.22424870e-01,
        2.51642165e-01, 4.65961900e-01, 4.01096905e-01, 2.23227107e-01,
        3.01693318e-01, 2.63117463e-01, 1.99677709e-01, 2.93918236e-01,
        3.00865757e-01, 1.12973480e-01, 3.32717320e-01, 4.97047395e-02,
        2.00098289e-01, 2.21193622e-01, 3.03280710e-01, 2.31095376e-01,
        1.83633295e-01, 1.98388238e-01, 8.18752581e-02, 2.49858153e-01,
        3.46496227e-01, 2.10717352e-01, 1.23845788e-01, 8.45406525e-02,
        5.98857457e-02, 1.74356371e-01, 2.76615940e-01, 3.44919413e-01,
        5.54968046e-01, 6.22081087e-01, 1.21925213e-01, 3.23724442e-01,
        1.52611693e-01, 1.28857781e-01, 1.10719288e-01, 1.76124471e-01,
        1.65819462e-01, 1.25088970e-01, 1.11151788e-01, 6.58394485e-02,
        1.07198421e-01, 6.55437065e-02, 6.67699483e-02, 7.88811159e-02,
        4.19152200e-02, 6.80937280e-02, 7.57433654e-02, 4.14555889e-02,
        4.64901095e-02, 1.01348077e-01, 0.00000000e+00, 6.81171538e-02,
        2.90678579e-02, 4.54689934e-02, 3.48499496e-02, 1.90394440e-02,
        4.55375621e-02, 1.19510447e-02, 7.92281878e-02, 1.24313159e-02,
        3.13550917e-02, 8.65548291e-03, 3.82981240e-02, 5.88751406e-02,
        1.20256414e-01, 3.52871961e-02, 3.42525126e-02, 1.16290936e-01,
        6.26159686e-01, 7.38202623e-01, 2.17138874e-01, 4.34653667e-01,
        2.67626232e-01, 2.31598935e-01, 1.79965327e-01, 2.96839573e-01,
        2.94108696e-01, 2.53013072e-01, 2.21720628e-01, 1.43901246e-01,
        2.36183067e-01, 1.56978786e-01, 1.67236674e-01, 1.95795865e-01,
        1.06051352e-01, 1.81696298e-01, 1.77533434e-01, 1.16258144e-01,
        1.08507750e-01, 2.44598141e-01, 0.00000000e+00, 1.86373894e-01,
        9.28962839e-02, 1.30317640e-01, 1.03913134e-01, 6.59988197e-02,
        1.27712692e-01, 4.41196609e-02, 1.99541010e-01, 4.48504496e-02,
        9.00040597e-02, 3.16976662e-02, 9.93440797e-02, 1.45913137e-01,
        2.55275105e-01, 1.02161713e-01, 9.62438231e-02, 2.64650817e-01,
        5.90737317e-01, 6.72732193e-01, 8.25044182e-01, 7.34220335e-01,
        6.86770178e-01, 6.80651146e-01, 7.09357510e-01, 7.00231253e-01,
        6.56916474e-01, 7.35933879e-01, 8.25938084e-01, 7.98659830e-01,
        6.28195330e-08, 3.56747034e-05, 5.82313303e-03, 2.64403471e-02,
        8.63902478e-02, 2.51786761e-02, 8.65266465e-03, 1.27497072e-03,
        2.62465903e-03, 4.40782191e-03, 1.88734099e-03, 1.45523808e-03,
        3.01455487e-03, 7.81538061e-04, 2.52805596e-04, 5.91318335e-05,
        1.26226477e-04, 2.60923908e-04, 4.16178371e-04, 1.52616652e-04,
        2.88250278e-05, 4.71829938e-05, 1.20304243e-04, 2.91039507e-04,
        5.55871541e-04, 8.18552445e-05, 1.96542680e-05, 1.14192898e-05,
        5.57523014e-05, 6.41537064e-05, 1.54652505e-05, 1.41346199e-05,
        2.64188056e-06, 7.19823282e-06, 1.11790720e-05, 1.40242150e-05,
        5.55790996e-06, 2.49158569e-06, 8.81481395e-06, 6.13580620e-06,
        6.04418253e-06, 3.03823329e-05, 1.43881083e-05, 5.40680676e-06,
        2.51611112e-06, 3.26747928e-06, 1.00159260e-05, 1.21891584e-04,
        8.80387764e-05, 2.02248711e-05, 4.84643551e-06, 1.50074882e-05,
        9.35335884e-05, 1.39923557e-05, 2.63146388e-06, 8.21077243e-06,
        3.06153614e-05, 8.08252263e-06, 1.58491658e-05, 1.27782180e-04,
        5.70109218e-05, 3.74933587e-05, 6.60659287e-05, 1.11777071e-04,
        9.41164668e-05, 4.77208182e-05, 3.86365145e-05, 1.33812607e-04,
        4.51480288e-05, 6.31044337e-06, 4.48864282e-05, 3.30622280e-05,
        4.43708789e-05, 2.35324813e-05, 1.91317304e-05, 1.36513128e-05,
        1.01835207e-04, 1.65716055e-04, 1.82979804e-04, 6.14741148e-04,
        2.72763004e-04, 2.62468321e-04, 1.53294605e-04, 3.68193793e-05,
        4.40840417e-05, 1.61007902e-05, 1.49412485e-05, 1.14846587e-05,
        2.01430537e-05, 2.72804323e-05, 9.84955396e-05, 6.02866947e-05,
        6.78600916e-05, 1.03892070e-04, 1.42312597e-04, 7.28895382e-05,
        7.31077728e-05, 3.25762060e-05, 1.68608905e-05, 1.70678936e-05,
        4.73865220e-05, 1.22744825e-04, 5.44508809e-05, 1.38428604e-04,
        3.08723092e-04, 1.64083242e-04, 6.78848827e-04, 1.61249642e-04,
        2.32819109e-04, 3.19544229e-04, 5.41292170e-04, 6.82567517e-04,
        5.93216311e-04, 9.16441776e-04, 1.77228662e-03, 1.21871936e-03,
        1.43464133e-03, 1.38911521e-03, 6.49787087e-04, 4.03007841e-04,
        3.08629945e-04, 1.91946570e-04, 2.73847235e-04, 2.36211099e-04,
        2.44167117e-04, 1.85495627e-04, 2.01866133e-04, 2.75992263e-04,
        3.13300732e-01, 1.06159816e-01, 1.66383654e-01, 2.75074069e-01,
        3.85477571e-01, 2.56641634e-01, 4.78211069e-01, 3.42688864e-01,
        4.75176806e-01, 6.00745747e-01, 2.83093048e-01, 7.37567914e-01,
        4.50698898e-01]];

        muestra = tf.tensor(v);

      
        model.then(function (res) {
            const prediction = res.predict(muestra);
            console.log(prediction);
    
            console.log(">>>>>>>>>>>>>>>>>>>>>>>>>>><");
            //console.log(prediction.);
            
        }, function (err) {
            console.log(err);
            
        });
        
        //res.json(prediction);
        res.json({"message": "hello tensorflow"});

    
});


/// routes
router.get('/test',(req,res) => {
    const data = [
        {
            "name": "Eduardo",
            "lastName": "Macetas",
            "age" : "27"
        },
        {
            "name": "David",
            "lastName": "Carpio",
            "age" : "27"
        },
        {
            "name": "Liz",
            "lastName": "Perez",
            "age" : "29"
        },
        {
            "name": "Eldest",
            "lastName": "11",
            "age" : "35"
        }
    ];
    res.json(data);
});


router.get("/writefile",(req,res) => {
    
    //var fs = require('fs');
    var stream = fs.createWriteStream("tmp/my_file.txt");
    stream.once('open', function(fd) {
    stream.write("My first row\n");
    stream.write("My second row\n");
    stream.end();
    });

    res.send("hello"); 
});



//insert
router.post('/',(req,res) => {
    ///req.body;
    console.log(req.body)

    res.json(req.body);
});




///////////////////////////////////////////////

router.post('/upload_system', upload.single("file"), function (req,res) {
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

        var spawn = require("child_process").spawn; 
        var process = spawn('python3',[currenPath+"/voice.py", currentPathFile] );
        process.stdout.on('data', function (data) {
            var r = JSON.parse(data.toString()).clasificacion;
            console.log("Class " + r);  
            res.json({"result": r}); // res
        });
        //TODO: handle errors
    });

    src.on('error', function(err) { 
      res.json({'result' : -1}); 
    });
  })

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



  router.post('/upload_test', upload.single("file"), function (req,res) {
    console.log("Received file" + req.file.originalname);
    var src = fs.createReadStream(req.file.path);
    var dest = fs.createWriteStream('uploads/' + req.file.originalname);

    var sv = Math.floor(Math.random() * 3);
    sv = sv+1;
    res.json({"result": sv});
  })



//connection with python
router.get('/helloml',(req,res) => {
    var currenPath = __dirname;
    ///console.log(currenPath);

    //We will have to create a childprocess in order tocall python script.
    var spawn = require("child_process").spawn; 
    //This process is called here.
    //var process = spawn('python3',[currenPath+"/ml.py",1,2] );
    var process = spawn('python3',[currenPath+"/voice.py", currenPath+"/flutter.wav"] );
    //We listen for 'data' event.
    process.stdout.on('data', function (data) {
        var r = JSON.parse(data.toString()).clasificacion;
        console.log("Class " + r);  
        res.json({"path" : currenPath ,"result" : r});  
    });
    //TODO: process ON ERROR
});


router.get('/home', function(req, res) {
    request('http://localhost:5000/flask', function (error, response, body) {
        console.error('error:', error); // Print the error
        console.log('statusCode:', response && response.statusCode); // Print the response status code if a response was received
        //console.log('body:', body);
        sms = JSON.parse(body);
        //console.log('sms:', sms["sms"]);
        res.json(sms);
      });     
});

//test function
router.get('/hola', function(req, res) {
    request({
        method: 'POST',
        url: 'http://localhost:5000/hola',
        json: {"nombre": "bar simpsom"}
    }, (error, response, body) => {
        console.log(error);
        console.log(body);
        res.json(body);
    });
});

router.post('/get_stress_level',(req,res) => {
    //console.log(req.body);
    var audio_path = req.body["audio_path"];
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





module.exports = router;






