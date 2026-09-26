// Intentional smells for apps-script-rg-gate discrimination (not product code).
function doPost(e) {
  const raw = e.postData.getDataAsString();
  const parsed = eval('(' + raw + ')'); // eval
  Logger.log(parsed); // Logger.log in lib/handler
  SpreadsheetApp.getUi().alert('bad'); // getUi in doPost file
  SpreadsheetApp.getActive().getSheetByName('Inbox').appendRow([parsed]); // write, no LockService
  return ContentService.createTextOutput('no');
}
