class LinkErrsToProblems < Mongoid::Migration
  def self.up
    puts "== Migrating from Errs to Problems..."

    puts "==== Copy err.klass to notice.klass..."
    Notice.all.each do |notice|
      if notice.err && (klass = notice.err['klass'])
        notice.update_attribute(:klass, klass)
      end
    end

    puts "==== Create a Problem for each Err..."
    Err.all.each do |err|
      if err['app_id'] && app = App.where(:_id => err['app_id']).first
        err.problem = app.problems.create
        err.save
      end
    end

    puts "==== Updating problem cached attributes..."
    Rake::Task["errbit:db:update_problem_attrs"].invoke
    puts "==== Updating notice counts..."
    Rake::Task["errbit:db:update_notices_count"].invoke
  end

  def self.down
  end
end

