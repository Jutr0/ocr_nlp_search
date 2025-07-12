require 'json'
require 'fileutils'

RSpec::Matchers.define :match_schema do |schema_name|
  RED = "\e[31m"
  GREEN = "\e[32m"
  RESET = "\e[0m"

  match do |actual_body|
    schema_path = get_spec_response_path(schema_name)

    @actual = JSON.parse(normalize(actual_body))

    unless File.exist?(schema_path)
      FileUtils.mkdir_p(File.dirname(schema_path))
      File.write(schema_path, JSON.pretty_generate(@actual))
      puts "Created schema at #{schema_path}"
      next true
    end

    @expected = JSON.parse(File.read(schema_path))

    @expected_str = JSON.pretty_generate(@expected)
    @actual_str = JSON.pretty_generate(@actual)

    @diffs = []
    @expected_str.lines.each_with_index do |exp_line, idx|
      act_line = @actual_str.lines[idx]
      exp = exp_line.chomp
      act = act_line ? act_line.chomp : ''
      @diffs << { line: idx + 1, exp: exp, act: act } if exp != act
    end

    @expected == @actual
  end

  failure_message do
    msg = +"Expected JSON to match schema '#{schema_name}'\n"
    msg << "Expected:\n#{@expected_str}\n"
    msg << "Actual:\n#{@actual_str}\n"

    if @diffs.any?
      msg << "Diffs (expected vs actual):\n"
      runs = []

      @diffs.each do |diff|
        if runs.empty? || diff[:line] != runs.last.last[:line] + 1
          runs << [diff]
        else
          runs.last << diff
        end
      end
      runs.each do |lines|
        msg << lines.select { |line| line[:exp].present? }.map { |line| "#{RED}-  #{line[:exp]}\n#{RESET}" }.join("")
        msg << lines.select { |line| line[:act].present? }.map { |line| "#{GREEN}+  #{line[:act]}\n#{RESET}" }.join("")
      end
    end

    msg
  end

  def normalize(body)
    body
      .gsub(/"id"\s*:\s*"[^"]*"/, '"id": "HIDDEN"')
      .gsub(/"url"\s*:\s*"[^"]*"/, '"url": "HIDDEN"')
  end
end

