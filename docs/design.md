# Raleigh Design

Imagine you have been tracking data about some things:


```markdown

// Focus Duration

| ID  | RecordDate | Duration | Push | Break |
| --- | ---------- | -------- | ---- | ----- |
| 1   | 2026-01-27 | 3:10     | 0    | 10    |
| 2   | 2026-01-28 | 3:07     | 5    | 10    |
| 3   | 2026-01-29 | 2:55     | 5    | 10    |

// Habit tracking

| ID  | RecordDate | Consecutive Days | Downtime |
| --- | ---------- | ---------------- | -------- |
| 1   | 2026-01-27 | 27               | 7        |
| 2   | 2026-02-14 | 10               | 7        |
| 3   | 2026-03-24 | 20               | 7        |

// Bench Press

| ID  | RecordDate | Weight | Reps | Sets |
| --- | ---------- | ------ | ---- | ---- |
| 1   | 2026-01-27 | 45     | 5    | 3    |
| 2   | 2026-01-28 | 45     | 5    | 3    |
| 3   | 2026-01-29 | 50     | 5    | 3    |

```

Now, we want to make an app that we can track these things locally with. 

- Needs a view where we are designing a set of data to track. We're defining the table - the column names and the data types.
- Needs a way to select which data set (table) we want to add a record to.
- Once we've decided which data-set we'll be adding data to, gives us a view for entering that data:

```
# Focus Duration

Duration |_______|

Push     |_______|

Break    |_______|

[ENTER]
```

- Entering the data saves it so that it is persistent on the device.
- `ID` and the `RecordDate` are automatically generated without user input. `RecordDate` might also need to be a `DateTime` type, rather than the pure `date` shown in my example tables.
- Needs a view for visualizing the data, showing the table in a nice GUI.
- Allow the ability to edit or delete a record while viewing the table.
- Allow exporting the data a JSON - maybe we even store it that way? 
	- I hate working with SQL, but if that turns out to be the best option, we can go with it (SQL Lite at the very most).
	- I want it to be easy to transfer the save file manually to a different device - so if it's just saved as JSON, I can just grab the JSON file. Otherwise I'll need an import/export process.
	- CSV might work as well.
	- Maybe Flutter/Dart has a preferred way of doing this sort of thing? Inform me, and then we'll decide.
- Cross platform. But with a focus in mind that this will likely be a mobile app.

OMG I'm basically designing a CRUD app, aren't I? I hate CRUD.




