const {Router} = require('express');
const router = Router()

const movies = require("../sample.json")
console.log(movies);

//get
router.get('/',(req,res) => {
    res.json(movies);
});


//insert
router.post('/',(req,res) => {
    const {title, director, year, rating} = req.body;
    if(title && director && year && rating){//validacion

        const id = movies.length+1;
        const newMovie = {...req.body, id};
        movies.push(newMovie);
        
        console.log(newMovie);
        res.json(movies);
    }else{
        //res.json({"error": "datos incorrectos"});
        res.status(500).json({"error": "datos incorrectos"});
    }
});

//delete
router.delete('/:id',(req,res) => {
    const { id } = req.params;
    console.log("id movie to delete:",id);
    res.send("eliminado, eliminado, eliminsdo, eliminaaadoooo");
});

//update
router.put('/:id',(req,res) => {
    const { id } = req.params;
    const {title, director, year, rating} = req.body;
    console.log("id movie:",id);
    console.log("body:",req.body);
    res.send("actualizado");
});



module.exports = router;




