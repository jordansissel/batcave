require "clamp"
require "faraday"
require "json"
require "insist"
require "clamp"

class BatCave::Command::GithubIssueMilestone < Clamp::Command
  option ["--log-level", "-l"], "LEVEL", "The log level. Default is 'warn'. Can be 'debug', 'info', 'warn', 'error'", :default => "warn" do |val|
    insist { ["warn", "debug", "info", "error"] }.include?(val.downcase)
    val.downcase.to_sym
  end
  option "--override", :flag, "Override milestone on an issue if one is already set.", :default => false

  parameter "USER/PROJECT", "The user/project repo name on github.", :attribute_name => "repo"
  parameter "ISSUE", "The issue number. Can be '-' to read issue numbers from stdin.", :attribute_name => :issue_number
  parameter "MILESTONE", "The milestone to set", :attribute_name => :milestone_name

  def logger
    @logger ||= Cabin::Channel.get
  end

  def execute
    logger.subscribe(STDOUT)
    logger.level = log_level
    logger[:repo] = repo
    logger[:milestone] = milestone_name

    # verify milestone exists
    milestones = client.milestones(repo)
    selector = proc { |m| m["title"] == milestone_name } 
    if milestones.none?(&selector)
      raise "No such milestone '#{milestone_name}' found in #{repo}"
    end
    milestone_number = milestones.find(&selector)["number"]

    @logger.debug("Found milestone number", :number => milestone_number)

    if issue_number == "-"
      STDIN.each_line do |issue_number|
        set_milestone(repo, issue_number.chomp, milestone_number)
      end
    else
      set_milestone(repo, issue_number, milestone_number)
    end
    0
  rescue RuntimeError => e
    puts "Error: #{e}"
    1
  rescue => e
    if logger.debug?
      logger.error("An error occurred", :exception => e, :backtrace => e.backtrace)
    else
      logger.error("An error occurred", :exception => e)
    end
    1
  end # def execute

  def set_milestone(repo, issue_number, milestone_number)
    logger[:issue] = issue_number

    # TODO(sissel): Verify issue exists
    issue = client.issue(repo, issue_number)
    if issue.milestone
      if issue.milestone.title == milestone_name
        @logger.debug("Skipping because milestone is already set", :current_milestone => issue.milestone.title)
        return
      end
      if issue.milestone.title != milestone_name
        if override?
          @logger.info("Milestone already set on issue, but override is given, so I will override it.", :current_milestone => issue.milestone.title)
        else
          @logger.info("Milestone already set on issue, skipping this issue.", :current_milestone => issue.milestone.title)
          #raise "Milestone is already set on '#{repo}' issue #{issue_number}"
        end
      end
    end
    client.update_issue(repo, issue_number, issue.title, issue.body, :milestone => milestone_number)
    logger.debug("Updated issue milestone successfully", :repo => repo)
  end # def execute

  def client
    # This requires you have ~/.netrc setup correctly
    # I don't know if it works with 2FA
    require "octokit"
    @client ||= Octokit::Client.new(:netrc => true).tap do |client|
      client.login
      client.auto_paginate = true
    end
  end

  def http
    @http ||= Faraday.new(:url => "https://github.com") do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end # http
  end # def http
end # class BatCave::Command::GithubIssueMilestone
