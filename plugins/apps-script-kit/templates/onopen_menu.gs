/**
 * Named boundary: container-bound UI via onOpen + getUi (valid context).
 * Keep this file free of doGet/doPost.
 * SPDX-License-Identifier: MIT
 */
function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Factory')
    .addItem('Ping', 'ping_')
    .addToUi();
}

function ping_() {}
