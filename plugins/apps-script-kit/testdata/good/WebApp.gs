function doGet() {
  return HtmlService.createHtmlOutput('<p>ok</p>');
}

function doPost(e) {
  const lock = LockService.getScriptLock();
  lock.waitLock(30000);
  try {
    SpreadsheetApp.getActive().getSheetByName('Inbox').appendRow([new Date(), e.postData.getDataAsString()]);
  } finally {
    lock.releaseLock();
  }
  return ContentService.createTextOutput('ok');
}
