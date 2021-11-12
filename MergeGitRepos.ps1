$projectA = ''
$projectB = ''
$newRepoDirectory = ''

clear
# CD to new repo directory
cd $newRepoDirectory

git remote add projectA $projectA
git fetch projectA
git merge projectA/master --allow-unrelated
git commit -m “Clean up initial file”
mkdir projectA
dir –exclude UI | %{git mv $_.Name projectA}
git commit -m “Move projectA files into subdir”


git remote add projectB $projectB
git fetch projectB 
git merge projectB/master --allow-unrelated
mkdir projectB
dir –exclude UI,API | %{git mv $_.Name projectB}
git commit -m “Move projectB files into subdir”


################# UI

$remoteBranches = git branch --all --remotes


ForEach ($branch in $remoteBranches) {

    $trimmed = $branch.Trim()
    git checkout -b $trimmed
    git merge -s recursive $trimmed

}

git remote remove projectA

git remote remove projectB
