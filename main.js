const {app, dialog, BrowserWindow, Menu} = require('electron')
const path = require('path')

let mainWindow

function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    icon: 'logo-alt.png',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js')
    }
  })

  let menu = Menu.buildFromTemplate([
    {
        label: 'Primaria',
        submenu: [
          {
            label: 'Capítulo 1:  Un tablero de bolitas movedizas',
            submenu: [
              {
                label: 'Lección 1: Explorando el tablero',
                click() { mainWindow.loadFile('lessons/1.html') }
              },
              {
                label: 'Lección 2: Las aventuras de Mukinita',
                click() { mainWindow.loadFile('lessons/2.html') }
              }
            ]
          },
          {
            label: 'Capítulo 2:  Un jardín de procedimientos',
            submenu: [
              {
                label: 'Lección 1: Sembrando futuro',
                click() { mainWindow.loadFile('lessons/3.html') }
              },
              {
                label: 'Lección 2: Rindiendo frutos',
                click() { mainWindow.loadFile('lessons/4.html') }
              }
            ]
          },
          {
            label: 'Capítulo 3:  Un día irrepetible con las abejas',
            submenu: [
              {
                label: 'Lección 1: La danza de la miel',
                click() { mainWindow.loadFile('lessons/5.html') }
              },
              {
                label: 'Lección 2: Campo de flores',
                click() { mainWindow.loadFile('lessons/6.html') }
              }
            ]
          },
          {
            label: 'Capítulo 4:  Una heladería con alternativas',
            submenu: [
              {
                label: 'Lección 1: Hay palito bombón helado',
                click() { mainWindow.loadFile('lessons/7.html') }
              },
              {
                label: 'Lección 2: Muchos sabores combinados',
                click() { mainWindow.loadFile('lessons/8.html') }
              }
            ]
          },
          {
            label: 'Capítulo 5:  Antiguas expresiones',
            submenu: [
              {
                label: 'Lección 1: La historia con fin',
                click() { mainWindow.loadFile('lessons/9.html') }
              },
              {
                label: 'Lección 2: Huellas del pasado',
                click() { mainWindow.loadFile('lessons/10.html') }
              }
            ]
          },
          {
            label: 'Capítulo 6:  Costumbres entrelazadas',
            submenu: [
              {
                label: 'Lección 1: Hilando fino',
                click() { mainWindow.loadFile('lessons/11.html') }
              },
              {
                label: 'Lección 2: Hay tela para rato',
                click() { mainWindow.loadFile('lessons/12.html') }
              }
            ]
          },
          {
            label: 'Capítulo 7:  Una vuelta por el universo',
            submenu: [
              {
                label: 'Lección 1: PlaNotas',
                click() { mainWindow.loadFile('lessons/13.html') }
              },
              {
                label: 'Lección 2: Mervetimara Jupsaturneplu',
                click() { mainWindow.loadFile('lessons/14.html') }
              }
            ]
          }
        ]
    },
    {
      label: 'Ayuda',
      submenu: [
        {
          label: 'Acerca de Murga',
          click() {
            dialog.showMessageBox({type: "info", title: "Acerca de Murga", message: "Murga es la aplicación offline de Mumuki"})
          }
        }
      ]
    }
  ])
  Menu.setApplicationMenu(menu);

  mainWindow.loadFile('chapters/1.html')

  //mainWindow.webContents.openDevTools()

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
