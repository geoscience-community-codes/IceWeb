function [sday,smon,syear,eday,emon,eyear,snum,enum]=enterdate();

flag = 1;
while (flag == 1),
	disp(' ');
        disp('Enter start date');
        sday = input('  day (1-31)  ? ');
        smon = input('  month (1-12)? ');
        syear= input('  year (YYYY) ? ');
        flag = checkdate(sday,smon,syear);
        if (flag == 1)
                disp('Please try again');
        end
end
flag = 1;
while (flag == 1),
	disp(' ');
        disp('Enter end date');
        eday = input('  day (1-31)  ? ');
        emon = input('  month (1-12)? ');
        eyear= input('  year (YYYY) ? ');
        flag = checkdate(eday,emon,eyear);
        if (flag == 1)
                disp('Please try again');
        end
end
snum=datenum(syear,smon,sday);
enum=datenum(eyear,emon,eday);

if snum>enum
	disp(' ');
        disp('Silly! Start date must be BEFORE end date!');
        exit;
end

enum=min(enum,now+9/24);

if enum==floor(enum)
	enum=enum+0.99999;
end
