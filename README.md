# TaskFlow – Jac Todo App

## Author
**Name:** Maya Hillegonds  
**UMID:** himaya  

## Project Description

TaskFlow is a multi-user todo application built using Jac with integrated AI features for task categorization and meal planning.

---

## Added Feature: Due Dates & Overdue Filter

This project includes a due date system that allows users to assign due dates to tasks, view when tasks are due, and filter to display only overdue tasks. This improves task organization and helps users prioritize urgent work. 

The implementation is located as a feature of AddTodo and ListTodos in `main.jac`. The styling has been edited to match the rest of the app and allows users to input dates for tasks with a calendar dropdown.

---

## Installation and Setup

### Create a virtual environment:

Remove any previously existing venv for a fresh start:
```
rm -rf .venv
```
create venv with py3.12 arm64: 
```
/opt/homebrew/opt/python@3.12/bin/python3.12 -m venv .venv
```
install pip: 
```
    $ python -m ensurepip --upgrade
    $ python -m pip install -U pip setuptools wheel
    $ python -m pip --version
```

install jaseci: `pip install jaseci`

run with: `jac start`

if bundle isn't built: `jac clean --all` then try again.

I used ollama to test this app. Install ollama or provide your own API key to run this app.