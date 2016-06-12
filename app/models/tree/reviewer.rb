module Tree
  class Reviewer
    def initialize(target)
      @target = target
      @organization = target.organization
      @memberships = organization.organization_memberships.includes(:reviewer)
    end

    def all_reviewers
      built_tree.parents.map(&:membership)
    end

    def all_reports
      built_tree.all_children.map(&:membership)
    end

    def direct_reports
      built_tree.children.map(&:membership)
    end

    private

    attr_reader :organization, :memberships, :target

    def built_tree
      @built_tree ||= begin
        tree = Node.new(target)
        build_parent_nodes(tree)
        build_child_nodes(tree)
      end
    end

    def build_parent_nodes(tree)
      current_node = tree

      while current_node.membership.reviewer
        current_node.parent = Node.new(current_node.membership.reviewer)
        current_node = current_node.parent
      end

      tree
    end

    def build_child_nodes(tree)
      frontier = [tree]

      while node = frontier.shift
        child_memberships = memberships_under_reviewer(node.membership)
        child_memberships.each do |membership|
          child_node = Node.new(membership)
          child_node.parent = node
          frontier << child_node
        end
      end

      tree
    end

    def memberships_under_reviewer(reviewer)
      memberships.select { |m| m.reviewer == reviewer }
    end
  end

  class Node
    attr_accessor :membership, :children, :parent

    def initialize(membership)
      @membership = membership
      @parent = nil
      @children = []
    end

    def parent=(node)
      node.children << self
      @parent = node
    end

    def parents
      arr = []
      node = parent

      while node
        arr << node
        node = node.parent
      end

      arr
    end

    def all_children
      arr = []
      frontier = [self]

      while node = frontier.shift
        arr << node.children
        frontier = frontier + node.children
      end

      arr.flatten
    end
  end
end
