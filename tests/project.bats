setup() {
	load 'helpers'

	common_setup

	TEMPDIR=$(mktemp -d)
	TEMPDIR2=$(mktemp -d)
}

@test "project init and update and info" {
	cd "$TEMPDIR" || exit

	"$DAGGER" project init ./ --name "github.com/foo/bar"
	test -d ./cue.mod/pkg
	test -d ./cue.mod/usr
	test -f ./cue.mod/module.cue
	contents=$(cat ./cue.mod/module.cue)
	[ "$contents" == 'module: "github.com/foo/bar"' ]

	#  ensure old 0.1 style .gitignore is removed
 	printf "# generated by dagger\ndagger.lock" > .gitignore

	"$DAGGER" project update
	test -d ./cue.mod/pkg/dagger.io
	test -d ./cue.mod/pkg/universe.dagger.io
	test -f ./cue.mod/pkg/.gitattributes
	run cat ./cue.mod/pkg/.gitattributes
	assert_output --partial "generated by dagger"

	test ! -f ./cue.mod/pkg/.gitignore

	run "$DAGGER" project info
	assert_success
	assert_output --partial "Current dagger project in:"
	assert_output --partial "$TEMPDIR"

	cd "$TEMPDIR2" || exit
	run "$DAGGER" project info
	assert_failure
	assert_output --partial "dagger project not found. Run \`dagger project init\`"
}
