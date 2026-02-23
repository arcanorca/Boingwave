/*
 * WindowMonitor.qml
 * Monitors visible windows on the current desktop/activity to determine
 * if the animation should be paused for power saving.
 *
 * Based on the proven approach from plasma-smart-video-wallpaper-reborn
 * by Luis Bocanegra (GPLv2+). Uses org.kde.taskmanager to detect windows
 * without requiring clicks, MouseArea, or DBus polling.
 */

import QtQuick
import org.kde.taskmanager 0.1 as TaskManager

Item {
    id: root

    /// Bind this to `wallpaper.parent?.screenGeometry ?? null` from main.qml
    property var screenGeometry

    /// True when any non-minimized window is visible on the current screen/desktop/activity
    property bool visibleWindowExists: false

    // Role references from AbstractTasksModel
    property var abstractTasksModel: TaskManager.AbstractTasksModel
    property var isWindow: abstractTasksModel.IsWindow
    property var isMinimized: abstractTasksModel.IsMinimized

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled
        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity
        screenGeometry: root.screenGeometry
        filterByVirtualDesktop: true
        filterByScreen: true
        filterByActivity: true
        filterMinimized: true

        onDataChanged: Qt.callLater(root.updateWindowState)
        onCountChanged: Qt.callLater(root.updateWindowState)
    }

    function updateWindowState() {
        let visible = false;
        for (let i = 0; i < tasksModel.count; i++) {
            const idx = tasksModel.index(i, 0);
            if (idx === undefined) continue;
            if (tasksModel.data(idx, isWindow) && !tasksModel.data(idx, isMinimized)) {
                visible = true;
                break;
            }
        }
        visibleWindowExists = visible;
    }

    Component.onCompleted: updateWindowState()
}
