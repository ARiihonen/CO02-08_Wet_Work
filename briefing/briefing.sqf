//More info: 
//https://community.bistudio.com/wiki/createDiaryRecord
//https://community.bistudio.com/wiki/createDiarySubject
#include "functions.sqf";
#include "..\logic\activeMods.sqf";

//Adds briefing file
player createDiarySubject ["Diary", "Diary"];

//Add new diary pages with caran_briefingFile. 
//If including variables, add them as a list to the end of the parameters list: ["ExampleSubject", "ExampleName", "ExampleFile", [ExampleParams]]
_notes = ["Diary", "Notes", "Notes.txt"] call caran_briefingFile;
_signal = ["Diary", "Signal", "Signal.txt"] call caran_briefingFile;
_intel = ["Diary", "Intel", "Intel.txt"] call caran_briefingFile;
_execution = ["Diary", "Execution", "Execution.txt"] call caran_briefingFile;
_mission = ["Diary", "Mission", "Mission.txt"] call caran_briefingFile;
_situation = ["Diary", "Situation", "Situation.txt"] call caran_briefingFile;