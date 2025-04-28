1. git clone
 ```
git clone git@github.com:turnaev/angular-builder.git
```
2. git add src as submodele
```
git submodule add [your_git_repa] ./src
```

3. change src
[package.json](src%2Fpackage.json) 
```
  "scripts": {
    "ng": "ng",
    "start": "ng serve --host 0.0.0.0 --port 4200 --open --live-reload=true --disable-host-check --public-host http://localhost:4200",
    "build": "ng build --output-path ./dist/ --progress --output-hashing=all",
    "watch": "ng build--output-path ./dist/ --progress --output-hashing=all --watch --configuration development",
    "test": "ng test"
  },
```

4. build dev container
```
make dev-build
```

5. install node_modules  
```
make console
npm install
```
6. start in serve mode
Change [docker-compose.dev.yml](docker-compose.dev.yml)
```
    #command: ["sleep", "infinity"] # npm install
    command: ["npm", "start"]
```
```
make console
http://localhost:4200
```

7. build app container
```
make console
ng build
make build
```
7. start app container
[docker](docker)
```
dc up -d
http://localhost
```
