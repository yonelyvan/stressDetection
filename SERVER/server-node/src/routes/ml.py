import sys 
import json

r = int(sys.argv[1]) + int(sys.argv[2])
x = {
    "clasificacion": r 
}

print(json.dumps(x)) 
