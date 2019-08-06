desc 'Annotate controller and model files with schema info'
task :annotate do
  Dir.chdir(Rails.root)
  rake_output_message(`annotate --sort -i 2>&1`)
  rake_output_message(`annotate --sort --model-dir app/hyperloop/models 2>&1`)
end