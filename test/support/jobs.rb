class PrintJob
  @queue = :normal
  def self.perform
    puts 'hello PrintJob'
  end
end

class EndlessJob
  @queue = :normal
  def self.perform
    Resque.enqueue(self)
  end
end
