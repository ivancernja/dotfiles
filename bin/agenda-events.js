// Today's and tomorrow's events straight from EventKit. Usage: osascript -l JavaScript agenda-events.js
ObjC.import('EventKit');
ObjC.import('Foundation');

function run() {
  const store = $.EKEventStore.alloc.init;
  let done = false, granted = false;
  if (store.requestFullAccessToEventsWithCompletion) {
    store.requestFullAccessToEventsWithCompletion(function (g) { granted = g; done = true; });
  } else {
    store.requestAccessToEntityTypeCompletion(0, function (g) { granted = g; done = true; });
  }
  const deadline = Date.now() + 15000;
  while (!done && Date.now() < deadline) {
    $.NSRunLoop.currentRunLoop.runModeBeforeDate(
      $.NSDefaultRunLoopMode, $.NSDate.dateWithTimeIntervalSinceNow(0.05));
  }
  if (!granted) return "DENIED";

  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const end = new Date(start.getTime() + 2 * 86400000);
  const pred = store.predicateForEventsWithStartDateEndDateCalendars(
    $.NSDate.dateWithTimeIntervalSince1970(start.getTime() / 1000),
    $.NSDate.dateWithTimeIntervalSince1970(end.getTime() / 1000),
    $());
  const events = store.eventsMatchingPredicate(pred);
  const out = [];
  for (let i = 0; i < events.count; i++) {
    const e = events.objectAtIndex(i);
    const s = new Date(e.startDate.timeIntervalSince1970 * 1000);
    const day = Math.floor((new Date(s.getFullYear(), s.getMonth(), s.getDate()) - start) / 86400000);
    const hh = String(s.getHours()).padStart(2, '0'), mm = String(s.getMinutes()).padStart(2, '0');
    const allDay = e.isAllDay;
    out.push([day, allDay ? 'all day' : hh + ':' + mm,
              ObjC.unwrap(e.title) || '(untitled)',
              ObjC.unwrap(e.calendar.title) || ''].join('\t'));
  }
  return out.join('\n');
}
