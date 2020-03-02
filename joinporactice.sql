select bs.sessionnumber, bsn.stagename from BPAsession bs
left join BPASessionLog_NonUnicode bsn
on bsn.sessionnumber = bs.sessionnumber

select * from bpasession
where sessionnumber = 310

print current_timestamp

update bpasession set enddatetime = current_timestamp where sessionnumber = 310

select sessionnumber, datediff(mi, startdatetime, enddatetime) as timeDifference from bpasession
order by timeDifference desc

RANK() OVER (
    [PARTITION BY processid ]
    ORDER BY sort_expression [ASC | DESC],


)