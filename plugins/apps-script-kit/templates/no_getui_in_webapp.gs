/**
 * Named boundary: web apps use HtmlService; never call *.getUi from doGet/doPost files.
 * Put container menus in a separate Menu.gs with onOpen only.
 * SPDX-License-Identifier: MIT
 */
function doGet() {
  return HtmlService.createHtmlOutput('<p>ok</p>');
}

function doPost(e) {
  return ContentService.createTextOutput('ok');
}
