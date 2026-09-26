function onOpen() {
  SpreadsheetApp.getUi()
    .createMenu('Factory')
    .addItem('Ping', 'ping_')
    .addToUi();
}

function ping_() {
  const rows = SpreadsheetApp.getActive().getDataRange().getValues();
  return { count: rows.length };
}
