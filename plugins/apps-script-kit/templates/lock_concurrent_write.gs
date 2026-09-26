/**
 * Named boundary: LockService around concurrent sheet writes (PSR Apps Script).
 * doPost / onFormSubmit writers must take a lock before appendRow/setValues.
 * SPDX-License-Identifier: MIT
 */
function doPost(e) {
  const lock = LockService.getScriptLock();
  lock.waitLock(30000);
  try {
    const sheet = SpreadsheetApp.getActive().getSheetByName('Inbox');
    sheet.appendRow([new Date(), e.postData.getDataAsString()]);
  } finally {
    lock.releaseLock();
  }
  return ContentService.createTextOutput('ok');
}
