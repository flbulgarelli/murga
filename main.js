const {app, BrowserWindow, Menu} = require('electron')
const path = require('path')

let mainWindow

function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  })

  let menu = Menu.buildFromTemplate([
    {
        label: 'Recorridos',
        submenu: [
            {
              label:'Primaria - Capitulo 1 - Primeros Programas',
              click() { mainWindow.loadFile('exercises/1529.html') }
            },
            {
              label:'Primaria - Capitulo 1 - Práctica Primeros Programas',
              click() { mainWindow.loadFile('exercises/1544.html') }
            },
            {
              label:'Primaria - Capitulo 2 - Procedimientos',
              click() { mainWindow.loadFile('exercises/1715.html') }
            },
            {
              label:'Primaria - Capitulo 2 - Práctica Procedimientos',
              click() { mainWindow.loadFile('exercises/1669.html') }
            },
        ]
    }
  ])
  Menu.setApplicationMenu(menu);

  mainWindow.loadFile('exercises/1715.html')

  mainWindow.webContents.openDevTools()

  mainWindow.on('closed', function () {
    mainWindow = null
  })
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On macOS it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') app.quit()
})

app.on('activate', function () {
  // On macOS it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) createWindow()
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
