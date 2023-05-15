select daily.*,
       (sum(daily.daily_amount) over (
      partition by
        action_type
      order by
        the_day)
           ) as acc_amount
from (select (
                 case contract_address
                     when {{nft_address}} then '{{name}}'
                     END
                 )                                         as action_type,
             count(0)                                      as daily_amount,
             format_datetime(evt_block_time, 'yyyy-MM-dd') as the_day
      from erc721_polygon.evt_Transfer
      where contract_address = {{nft_address}}
        and "from" = 0x0000000000000000000000000000000000000000
      group by
          contract_address,
          format_datetime(evt_block_time, 'yyyy-MM-dd')
      order by
          contract_address,
          format_datetime(evt_block_time, 'yyyy-MM-dd')) as daily
