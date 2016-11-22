#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSystemTrayIcon>
#include <QMessageBox>
#include <QAction>
#include <QMenu>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
//    QGuiApplication::setQuitOnLastWindowClosed(false);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QObject *root = 0;
    root = engine.rootObjects().at(0);

//    qDebug() << root;
//    QAction *minimizeAction = new QAction(QObject::tr("Mi&nimize"), root);
//    root->connect(minimizeAction, SIGNAL(triggered()), root, SLOT(hide()));
//    QAction *maximizeAction = new QAction(QObject::tr("Ma&ximize"), root);
//    root->connect(maximizeAction, SIGNAL(triggered()), root, SLOT(showMaximized()));
//    QAction *restoreAction = new QAction(QObject::tr("&Restore"), root);
//    root->connect(restoreAction, SIGNAL(triggered()), root, SLOT(showNormal()));
//    QAction *quitAction = new QAction(QObject::tr("&Quit"), root);
//    root->connect(quitAction, SIGNAL(triggered()), root, SLOT(quit()));

//    QMenu *trayIconMenu = new QMenu();
//    trayIconMenu->addAction(minimizeAction);
//    trayIconMenu->addAction(maximizeAction);
//    trayIconMenu->addAction(restoreAction);
//    trayIconMenu->addSeparator();
//    trayIconMenu->addAction(quitAction);

//    QSystemTrayIcon *tray = new QSystemTrayIcon();
//    tray->setContextMenu(trayIconMenu);
//    tray->setIcon(QIcon("qrc:/logo.png"));
//    tray->show();

    return app.exec();
}
