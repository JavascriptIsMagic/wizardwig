var
	fs = require('fs'),
	gulp = require('gulp'),
	sequence = require('run-sequence'),

	uglify = require('gulp-uglify'),
	rename = require('gulp-rename'),
	sourcemaps = require('gulp-sourcemaps'),
	coffee = require('gulp-coffee'),

	git = require('gulp-git'),
	bump = require('gulp-bump'),
	filter = require('gulp-filter'),
	tag = require('gulp-tag-version');

gulp.task('wizardwig:build', function() {
  gulp.src(__dirname + '/src/**/*.coffee')
		.pipe(sourcemaps.init())
		.pipe(coffee({ bare: true }))
		.pipe(rename({suffix: '.min'}))
		.pipe(uglify())
		.pipe(sourcemaps.write(__dirname + '/dist/', { addComment: false }))
    .pipe(gulp.dest(__dirname + '/dist'))
});

gulp.task('wizardwig:watch', function () {
	gulp.watch([__dirname + '/src/**/*'], ['wizardwig:build']);
});

function version(importance) {
	return gulp.src([
			__dirname + '/package.json',
			__dirname + '/bower.json'])
		.pipe(bump({type: importance}))
		.pipe(gulp.dest(__dirname + '/'))
		.pipe(git.commit('releasing ' + importance + ' version.'))
		.pipe(filter('package.json'))
		.pipe(tag());
}

gulp.task('wizardwig:patch', version.bind(null, 'patch'));
gulp.task('wizardwig:feature', version.bind(null, 'minor'));
gulp.task('wizardwig:release', version.bind(null, 'major'));
