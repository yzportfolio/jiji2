# coding: utf-8

require 'encase'
require 'set'

module Jiji::Model::Agents
  class AgentsUpdater

    def initialize(agent_registory,
      broker, graph_factory, notifier, logger)
      @agent_registory = agent_registory
      @broker          = broker
      @graph_factory   = graph_factory
      @notifier        = notifier
      @logger          = logger
    end

    def update(agents, agent_setting)
      new_agents = agent_setting.each_with_object({}) do |setting, r|
        uuid = setting[:uuid]
        begin
          r[uuid] = agents.include?(uuid) \
            ? update_agent(agents[uuid], setting) \
            : create_agent(setting)
        rescue => e
          @logger.error(e) if @logger
        end
      end
      agents.agents = new_agents
    end

    private

    def update_agent(agent, setting)
      agent.properties = setting[:properties]
      agent
    end

    def create_agent(setting)
      agent = @agent_registory.create_agent(
        setting[:name], setting[:properties] || {})
      inject_components_to(agent)
      agent
    end

    def inject_components_to(agent)
      agent.broker          = @broker
      agent.graph_factory   = @graph_factory
      agent.notifier        = @notifier
      agent.logger          = @logger
    end

  end
end