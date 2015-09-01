module.exports = (grunt) ->
  require('time-grunt') grunt

  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['clean', 'coffee']
  grunt.registerTask 'test', ['mochaTest:unit']

  grunt.initConfig
    bump:
      options:
        pushTo: 'origin'

    clean: ['lib/']

    coffee:
      src:
        expand: true
        cwd: 'src/'
        src: ['**/*.coffee']
        dest: 'lib/'
        ext: '.js'

    mochaTest:
      unit:
        options:
          reporter: 'dot'
          require: [
            'coffee-script/register'
            'spec/spec-global.coffee'
          ]
        src: [
          'spec/**/*.coffee'
        ]

    watch:
      src:
        files: ['src/**/*.coffee']
        tasks: ['coffee:src']
      test:
        files: ['src/**/*.coffee', 'spec/**/*.coffee']
        tasks: ['test']
