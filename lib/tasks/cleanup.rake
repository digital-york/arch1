namespace :cleanup do
  require 'csv'

  desc "TODO"
  task registers: :environment do

    Register.all.each do |r|

      if r.preflabel == 'Abp Reg 32: Richard Neile (1632-1640):  John Williams (1641-1650)'
        r.preflabel = 'Abp Reg 32: Samuel Harsnett (1619-1631), Richard Neile (1632-1640), John Williams (1641-1650)'
        r.save
      end

      if r.preflabel == 'Abp Reg 5: Henry Neward (1298-1296)'
        r.preflabel = 'Abp Reg 5: Henry Newark (1298-1296)'
        r.save
      end

      if r.preflabel == 'Abp Reg 8A: William Greenfield (1306-1315)'
        r.preflabel = 'Abp Reg 8A: Greenfield, Visitation of Durham, deaneries of Alnwick, Bamburgh, Corbridge, Darlington and Newcastle upon Tyne, 1311'
        r.save
      end

      if r.preflabel == 'Abp Reg 8B: William Greenfield (1306-1315)'
        r.preflabel = 'Abp Reg 8B: Greenfield, Visitation of Durham, deaneries of Alnwick, Bamburgh, Corbridge, Darlington and Newcastle upon Tyne, 1311 (contemporary copy of 8A)'
        r.save
      end

      if r.preflabel == 'Abp Reg 10: William La Zouche (1342-1352)'
        r.preflabel = 'Abp Reg 10: William Zouche (1342-1352)'
        r.save
      end

      if r.preflabel == 'Abp Reg 13: [Alexander Neville] (1374-1388)'
        r.preflabel = 'Abp Reg 13: Formulary, including Visitation of Beverley, Mar-May 1381'
        r.save
      end

      if r.preflabel == 'Abp Reg 24: Thomas Rotherham (1480-1500)'
        r.preflabel = 'Abp Reg 24: George Neville (1465-1476), duplicate to 1487'
        r.save
      end

      if r.preflabel == 'Abp Reg 16: Richard Le Scrope (1398-1405)'
        r.preflabel = 'Abp Reg 16: Richard Scrope (1398-1405)'
        r.save
      end

      if r.preflabel == 'Abp Reg 22: George Neville (1465-1476) Part II'
        r.preflabel = 'Abp Reg 22: George Neville (1465-1476), Laurence Booth (1476-1480)'
        r.save
      end

    end

  end
end

