module SortingOffice
  class Normalise

    def initialize(address)
      @original = adddress
      @address = address
    end

    def self.normalise
      t1 = Time.now
      
      csvHeader = ["MPAN_CORE","Raw Address","matched","saon","paon","street","locality","town","postcode"].to_csv
      f = File.open("/home/richardt/software-projects/address-matching/data/norm.csv", 'w')
      f.puts(csvHeader)
      CSV.open("/home/richardt/software-projects/address-matching/data/test.addresses.csv",headers: true) do |address|
        addresses = address.each
        addresses.select do |row|
          id = row['id']
          #raw =  row['raw.address'] + "," + row['Postcode']
          raw =  row['raw.address']
          
          #Create address object and attempt match
          begin
            match =  SortingOffice::Address.new(raw)
            match.parse
          rescue
            print("Error: ID=" + id + "\n")
            f.puts([id, raw, "false"].to_csv)
          end
          
          if match.postcode.nil?
            print("No match for " + id + "\n")
            rowdata = [id, raw, "false"].to_csv
            f.puts(rowdata)
          else
            rowdata = [id,
                       raw,
                       "true",
                       match.saon,
                       match.paon,
                       match.street.try(:name).try(:titleize),
                       match.locality.try(:name),
                       match.town.try(:name).try(:titleize),
                       match.postcode.try(:name)
                      ].to_csv
            f.puts(rowdata)
          end
        end 
      end

      f.close

      t = Time.now - t1
      print("Completed in ")
      print(t)
      print(" secs \n")
    end
  end
end
