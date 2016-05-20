require 'securerandom'
require 'thread'

module KeyServer
  class KeyServerClass
    attr_reader :keys
    attr_reader :used

    def initialize
      @keys = Hash.new
      @used = Hash.new
      @max_size = 1000
      @lock = Mutex.new
    end

    def create_keys(size)
      create_count = 0
      raise ArgumentError unless size > 0
      while @keys.size < @max_size && create_count < size
        key = SecureRandom.hex.to_sym
        @lock.synchronize {
          if @keys[key.to_sym] == nil
            @keys[key.to_sym] = {created_at: Time.now, ttl: 300}
            create_count += 1
          end
        }
      end
    end

    def get_key_info(k)
      val = nil
      @lock.synchronize {
        val = @used[k.to_sym]
      }
      val
      end

    def get_free_key
      k,v = nil,nil
      @lock.synchronize {
        k,v = @keys.first
        if k != nil
          @used[k.to_sym] = {assigned_at: Time.now}
          @keys.delete(k.to_sym)
        end
      }
      return k
    end

    def release_key(k)
      if @used[k.to_sym] == nil
        return false
      else
        @lock.synchronize {
          @used.delete(k.to_sym)
          @keys[k.to_sym] = {created_at: Time.now, ttl: 300} 
        } 
      end
      return true 
    end
    
    def delete_key(k)
      if @used[k.to_sym] == nil
        false
      else
        @lock.synchronize {
          @used.delete(k.to_sym)
        }
        true
      end
    end

    def keepalive(k)
       if @keys[k.to_sym] == nil
         if @used[k.to_sym] == nil
           false
         else
           @lock.synchronize {
             @used[k.to_sym] = {assigned_at: Time.now}
           }
         end
       else
         @lock.synchronize {
           @keys[k.to_sym] = {created_at: Time.now, ttl: 300}
         }
       end
    end

    def freeup_keys
      @used.each { |x,v|
        @lock.synchronize  {
          if Time.now - @used[x][:assigned_at] > 60
              @used.delete(x)
              @keys[x] = {created_at: Time.now, ttl: 300}
          end
        } 
      }
      @keys.each { |x,v|
        @lock.synchronize {
          if Time.now - @keys[x][:created_at] > 300
            @keys.delete(x)
          end
        }
      }
    end
  end
end

