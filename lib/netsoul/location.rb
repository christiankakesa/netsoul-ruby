module Netsoul
  class Location
    class << self
      def get(ip)
        locations.each do |key, val|
          res = ip.match(/^#{val}/)
          if res
            res = "#{key}"
            return res
          end
        end
        'ext'.freeze
      end

      # rubocop:disable Metrics/AbcSize
      def locations
        {
          'lab-cisco-mid-sr': '10.251.'.freeze,
          etna: '10.245.'.freeze,
          lse: '10.227.42.'.freeze,
          'sda-1': '10.227.4.'.freeze,
          lab: '10.227.'.freeze,
          'lab-tcom': '10.226.7.'.freeze,
          'lab-acu': '10.226.6.'.freeze,
          'lab-console': '10.226.5.'.freeze,
          'lab-mspe': '10.226.'.freeze,
          epitanim: '10.225.19.'.freeze,
          epidemic: '10.225.18.'.freeze,
          'sda-2': '10.225.10.'.freeze,
          cycom: '10.225.8.'.freeze,
          epx: '10.225.7.'.freeze,
          prologin: '10.225.6.'.freeze,
          nomad: '10.225.2.'.freeze,
          assos: '10.225.'.freeze,
          sda: '10.224.14.'.freeze,
          www: '10.223.106.'.freeze,
          episport: '10.223.104.'.freeze,
          epicom: '10.223.103.'.freeze,
          'bde-epita': '10.223.100.'.freeze,
          omatis: '10.223.42.'.freeze,
          ipsa: '10.223.15.'.freeze,
          lrde: '10.223.13.'.freeze,
          cvi: '10.223.7.'.freeze,
          epi: '10.223.1.'.freeze,
          pasteur: '10.223.'.freeze,
          bocal: '10.42.42.'.freeze,
          sm: '10.42.'.freeze,
          vpn: '10.10.'.freeze,
          adm: '10.1.'.freeze,
          epita: '10.'.freeze
        }
      end
    end
  end
end
