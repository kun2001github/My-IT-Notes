import requests

cookies = {
    'cna': '8RsUH973cyEBASQOBH5W92Jb',
    't': '6dcc9380a98e8a4a2b81fabf083069dd',
    'unb': '3963161478',
    'cookie2': '1d9e8df4d6492722a27f59b61aae0320',
    '_samesite_flag_': 'true',
    '_tb_token_': '3ee50d630a9bf',
    'havana_lgc2_77': 'eyJoaWQiOjM5NjMxNjE0NzgsInNnIjoiZTA2NGE5ZjA3YmE5YTY2MWVmYTJiOWZlMWZjNjEzZmEiLCJzaXRlIjo3NywidG9rZW4iOiIxZzl6cC0yWUFJczdrckEyVHE1WEl3QSJ9',
    '_hvn_lgc_': '77',
    'havana_lgc_exp': '1729946874110',
    'isg': 'BB4epTh39LLc4SCg1fisqb4wb7Rg3-JZVZb_GcinWWFc67rFMm_GaAka5fdnU9px',
    'xlly_s': '1',
    'sgcookie': 'E100X8Bi00WqkYReztUmUCW0Baul1ZDyKi3RrxYVZXFZF%2BHLgNh1eEhx7ZfjBHVt0Rc0u3LnbECyladrG%2BNcbShi2uZ3bDIwBBrBPkyQGD2AQFCuPFcQhe31VlJNUzRM6fhC',
    'csg': 'ccd4365e',
    'sdkSilent': '1728227155259',
    'mtop_partitioned_detect': '1',
    '_m_h5_tk': '361d56325db91faaeb3087153a73adb1_1728195415812',
    '_m_h5_tk_enc': '78158080a46e36a98c0ad6d985b51733',
    'tfstk': 'gq5mtOVPGtJX65DWfzRbIGSMny2JMqO63Gh9XCKaU3-SDmhA7cjG4MQxM1QwjGjJVGv_lhKwjGQNHzFL9Z_X1ClgvWFdFg9H7sxZXC7X4Hqx9kFL9Zy2lCQzvsedhftD7C823xJzrFLqufSwQb7yVFTZ0Fl4ra-W4F-Z3E-PzeYM7mSw_zbyVFhqKog2Y1WNao_D4wVXm4fWoKxFun7Ak_5ZvH72qflwma90kZ-o_f55Fo04DnyIyhOvc1YcfWGXgdXCWFj0ijSGR_skzMPi9n75J9pfgRhpKQxDBsSgjAYcpij60Zoq3eADmp52FqzcrdWlZIC4fv_RrnJHwTe7Dddcm9tB38Z5jaxAbsvrmuKOpaC2EMr-ZG9GdNLGmScVYgPsUvRzkfTzW_ksCK8WrHezms3ICMc8Kz4odO92PexLrzDsCK8WrHUurvZ63UTHv',
}

headers = {
    'accept': 'application/json',
    'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
    'content-type': 'application/x-www-form-urlencoded',
    # 'cookie': 'cna=8RsUH973cyEBASQOBH5W92Jb; t=6dcc9380a98e8a4a2b81fabf083069dd; unb=3963161478; cookie2=1d9e8df4d6492722a27f59b61aae0320; _samesite_flag_=true; _tb_token_=3ee50d630a9bf; havana_lgc2_77=eyJoaWQiOjM5NjMxNjE0NzgsInNnIjoiZTA2NGE5ZjA3YmE5YTY2MWVmYTJiOWZlMWZjNjEzZmEiLCJzaXRlIjo3NywidG9rZW4iOiIxZzl6cC0yWUFJczdrckEyVHE1WEl3QSJ9; _hvn_lgc_=77; havana_lgc_exp=1729946874110; isg=BB4epTh39LLc4SCg1fisqb4wb7Rg3-JZVZb_GcinWWFc67rFMm_GaAka5fdnU9px; xlly_s=1; sgcookie=E100X8Bi00WqkYReztUmUCW0Baul1ZDyKi3RrxYVZXFZF%2BHLgNh1eEhx7ZfjBHVt0Rc0u3LnbECyladrG%2BNcbShi2uZ3bDIwBBrBPkyQGD2AQFCuPFcQhe31VlJNUzRM6fhC; csg=ccd4365e; sdkSilent=1728227155259; mtop_partitioned_detect=1; _m_h5_tk=361d56325db91faaeb3087153a73adb1_1728195415812; _m_h5_tk_enc=78158080a46e36a98c0ad6d985b51733; tfstk=gq5mtOVPGtJX65DWfzRbIGSMny2JMqO63Gh9XCKaU3-SDmhA7cjG4MQxM1QwjGjJVGv_lhKwjGQNHzFL9Z_X1ClgvWFdFg9H7sxZXC7X4Hqx9kFL9Zy2lCQzvsedhftD7C823xJzrFLqufSwQb7yVFTZ0Fl4ra-W4F-Z3E-PzeYM7mSw_zbyVFhqKog2Y1WNao_D4wVXm4fWoKxFun7Ak_5ZvH72qflwma90kZ-o_f55Fo04DnyIyhOvc1YcfWGXgdXCWFj0ijSGR_skzMPi9n75J9pfgRhpKQxDBsSgjAYcpij60Zoq3eADmp52FqzcrdWlZIC4fv_RrnJHwTe7Dddcm9tB38Z5jaxAbsvrmuKOpaC2EMr-ZG9GdNLGmScVYgPsUvRzkfTzW_ksCK8WrHezms3ICMc8Kz4odO92PexLrzDsCK8WrHUurvZ63UTHv',
    'origin': 'https://www.goofish.com',
    'priority': 'u=1, i',
    'referer': 'https://www.goofish.com/',
    'sec-ch-ua': '"Microsoft Edge";v="129", "Not=A?Brand";v="8", "Chromium";v="129"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-site',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0',
}

params = {
    'jsv': '2.7.2',
    'appKey': '12574478',
    't': '1728188037129',
    'sign': '96d7f43dfb3b15990c302a5cca8e69d7',
    'v': '1.0',
    'type': 'originaljson',
    'accountSite': 'xianyu',
    'dataType': 'json',
    'timeout': '20000',
    'AntiCreep': 'true',
    'AntiFlool': 'true',
    'api': 'mtop.taobao.idlehome.home.webpc.feed',
    'sessionOption': 'AutoLoginOnly',
    'spm_cnt': 'a21ybx.home.0.0',
}

data = {
    'data': '{"itemId":"","pageSize":30,"pageNumber":6,"machId":""}',
}

response = requests.post(
    'https://h5api.m.goofish.com/h5/mtop.taobao.idlehome.home.webpc.feed/1.0/',
    params=params,
    cookies=cookies,
    headers=headers,
    data=data,
).json()
print(response)