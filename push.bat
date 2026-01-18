@echo off
cd /d "C:\development\learn_app_dev\daily_coding_questions_app"
echo Aborting any ongoing rebase...
git rebase --abort 2>nul
echo.
echo Current branch:
git branch
echo.
echo Git status:
git status
echo.
echo Pushing to GitHub...
git push --force origin main
echo.
echo Done!
