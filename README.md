# terraform-aws-api-gateway-modules

- aws api gateway의 aws_api_gateway_resource 이하 리소스들을 생성하기 위한 모듈입니다.
- 해당 모듈을 적용한 live 코드는 [terraform-aws-api-gateway-modules-live](https://github.com/birdviewdev/terraform-aws-api-gateway-live) 에서 확인할 수 있습니다. 


## How to use
#### 아래 코드에서 사용되는 var.args 는 [terraform-aws-api-gateway-live](https://github.com/birdviewdev/terraform-aws-api-gateway-live/blob/feature/SV-9216.transfer_api_gateway_to_terraform/hwahae-api/common/outputs.tf)에서 확인할 수 있습니다.


## 1. 일반 API 추가
### 디폴트값
- `method_response_map` 파라미터에 별도의 값을 넣어주지 않으면 디폴트값이 들어갑니다.
- ** 주의) `method_response_map` 파라미터는, status_code = 200일 때의 정보가 들어가는 것이 디폴트이므로 아예 없는 경우에는 {} 를 넣어줘야 합니다.
  ```hcl
    # 디폴트값
    method_response_map = { 
      200 = {
        response_models     = {}
        response_parameters = {}
      }
    }
    # 200 응답도 설정하고 싶지 않을 때
    method_response_map = {}
  ```

### 디폴트 케이스
- 모든 파라미터에 디폴트 값을 사용할 경우 integration_uri만 넣어주면 됩니다.
```hcl
module "nickname_resources" {
  source      = "app.terraform.io/hh-devops/api-gateway-modules/aws"
  version     = "0.0.4"
  rest_api_id = var.args.rest_api_id
  parent_id   = var.parent_id
  path_part   = "nickname"

  method_values = {
    GET = {
      integration_uri = "http://$${stageVariables.HWAHAE_SERVER_API_ALB}/users/nickname"
    }
  }
}
```

### 복합 케이스 
- 모든 파라미터는 아래와 같이 개별적으로 주입해줄 수 있습니다. 
```hcl
module "brands_resources" {
  source      = "app.terraform.io/hh-devops/api-gateway-modules/aws"
  version     = "0.0.4"
  rest_api_id = var.args.rest_api_id
  parent_id   = var.parent_id
  path_part   = "brands"
  
  # method_values 에 있는 모든 메소드가 공통으로 갖는 값을 넣어줍니다. 
  common_values = {
    authorization = var.args.authorization.CUSTOM
    authorizer_id = var.args.hwahae_authorizer_id_map.default
  }

  method_values = {
    GET = {
      method_response_map = {
        200 = {
          response_models = var.args.response_models_empty
          response_parameters = {
            "method.response.header.Content-Type" : "false"
          },
        }
      }
      integration_uri               = "http://$${stageVariables.HWAHAE_SERVER_API_ALB}/$${stageVariables.version}/search/brands"
      integration_request_templates = var.args.request_templates_status_200
      integration_response_map = {
        200 = {
          response_parameters = {
            "method.response.header.Access-Control-Allow-Origin" = var.args.all_origin
          }
        }
        400 = { selection_pattern = "4\\d{2}" }
        500 = { selection_pattern = "5\\d{2}" }
      }
    }

    POST = {
      method_request_parameters = {
        "method.request.header.Content-Type" = "false"
        "method.request.path.id"             = "true"
      }
      integration_request_parameters = {
        "integration.request.header.Content-Type" = "method.request.header.Content-Type"
        "integration.request.path.id"             = "method.request.path.id"
      }
      integration_uri = "http://$${stageVariables.HWAHAE_SERVER_API_ALB}/$${stageVariables.version}/search/brands2"
    }
  }
}
```

## 2. HTTP_PROXY 통합 API 추가
### 디폴트값
- ANY 메소드의 경우, 아래의 파라미터에 별도의 값을 넣어주지 않으면 디폴트값이 들어갑니다.
  - `method_request_parameters`
  - `method_response_map`
  - `integration_cache_key_parameters`
  - `integration_request_parameters`
  ```hcl
    method_request_parameters = {
      "method.request.path.proxy" = true
    }
    method_response_map              = {}
    integration_cache_key_parameters = ["method.request.path.proxy"]
    integration_request_parameters = {
      "integration.request.path.proxy" = "method.request.path.proxy"
    }
  ```
    
### 디폴트 케이스
- 모든 파라미터에 디폴트 값을 사용할 경우 integration_uri만 넣어주면 됩니다.
```hcl
module "proxy_resources" {
  source      = "app.terraform.io/hh-devops/api-gateway-modules/aws"
  version     = "0.0.7"
  rest_api_id = var.args.rest_api_id
  parent_id   = var.parent_id
  path_part   = "{proxy+}"

  method_values = {
    ANY = {
      integration_uri = "http://$${stageVariables.AD_SERVING_SERVER_API_ALB}/{proxy}"
    }
  }
}
```

### 복합 케이스
- 모든 파라미터는 아래와 같이 개별적으로 주입해줄 수 있습니다. 
```hcl
module "proxy_resources" {
  source      = "app.terraform.io/hh-devops/api-gateway-modules/aws"
  version     = "0.0.7"
  rest_api_id = var.args.rest_api_id
  parent_id   = var.parent_id
  path_part   = "{proxy+}"

  method_values = {
    ANY = {
    method_request_parameters = {
      "method.request.path.proxy"                = true
      "method.request.header.hwahae-app-version" = true
    }
    method_response_map = {
      404 = {}
    }
    integration_cache_key_parameters = ["xxx"]
    integration_request_parameters = {
      "integration.request.path.proxy"                = "method.request.path.proxy"
      "integration.request.header.hwahae-app-version" = "method.request.header.hwahae-app-version"
    }
      integration_uri = "http://$${stageVariables.AD_SERVING_SERVER_API_ALB}/{proxy}"
    }
  }
}
```


## 3. CORS 활성화(OPTIONS 추가) 케이스
### 디폴트값
- OPTIONS 메소드의 경우, 아래의 파라미터에 별도의 값을 넣어주지 않으면 디폴트값이 들어갑니다.
  - `method_response_map`,
  - `integration_type`
  - `integration_request_templates`
  ```hcl
      # options 메소드의 method_response_map 디폴트값
      method_response_map = {
        200 = {
          response_models = {
            "application/json" = "Empty"
          }
          response_parameters = {
            "method.response.header.Access-Control-Allow-Headers" = "false"
            "method.response.header.Access-Control-Allow-Methods" = "false"
            "method.response.header.Access-Control-Allow-Origin"  = "false"
          }
        }
      }
      # options 메소드의 integration_request_templates 디폴트값
      integration_request_templates = {
        "application/json" = "{\"statusCode\": 200}"
      }
        
      # options 메소드의 integration_type 디폴트값
      integration_type = "MOCK"
  ```
  

### 디폴트 케이스
- 모든 파라미터에 디폴트 값을 사용할 경우 integration_response_map만 넣어주면 됩니다.
```hcl
module "brands_resources" {
  source      = "app.terraform.io/hh-devops/api-gateway-modules/aws"
  version     = "0.0.4"
  rest_api_id = var.args.rest_api_id
  parent_id   = var.parent_id
  path_part   = "brands"

  method_values = {
    OPTIONS = {
      integration_response_map = {
        200 = {
          response_parameters = {
            "method.response.header.Access-Control-Allow-Headers" = "'Origin, Authorization, Content-Type, Content-Range, Content-Disposition, Content-Description, X-Requested-With, X-ACCESS_TOKEN, X-Amz-Date, X-Api-Key, X-Amz-Security-Token, Hwahae-User-Id, Hwahae-App-Version, Hwahae-Device-Scale, Hwahae-Timestamp, Hwahae-Platform, Hwahae-Signature, Hwahae-Device-Id'"
            "method.response.header.Access-Control-Allow-Methods" = var.args.all_methods
            "method.response.header.Access-Control-Allow-Origin"  = var.args.all_origin
          }
        }
      }
    }
  }
}
```

### 복합 케이스
- 모든 파라미터는 아래와 같이 개별적으로 주입해줄 수 있습니다. 
```hcl
module "brands_resources" {
  source      = "app.terraform.io/hh-devops/api-gateway-modules/aws"
  version     = "0.0.4"
  rest_api_id = var.args.rest_api_id
  parent_id   = var.parent_id
  path_part   = "brands"

  method_values = {
    OPTIONS = {
      method_response_map = {
        200 = {
          response_parameters = {
            "method.response.header.Access-Control-Allow-Headers" = "false"
            "method.response.header.Access-Control-Allow-Origin"  = "false"
          }
        }
      }
      method_request_parameters = {
        "method.request.header.hwahae-app-version" = "false"
        "method.request.header.hwahae-platform"    = "false"
      }
      integration_request_templates = null
      integration_response_map = {
        200 = {
          response_parameters = {
            "method.response.header.Access-Control-Allow-Headers" = "'Origin,Authorization,Content-Type,Content-Range,Content-Disposition,Content-Description,X-Requested-With,X-ACCESS_TOKEN,X-Amz-Date,X-Api-Key,X-Amz-Secintegration_urity-Token,Hwahae-User-Id,Hwahae-App-Version,Hwahae-Device-Scale,Hwahae-Timestamp,Hwahae-Platform,Hwahae-Signature,Hwahae-Device-Id'"
            "method.response.header.Access-Control-Allow-Methods" = var.args.all_methods
            "method.response.header.Access-Control-Allow-Origin"  = var.args.all_origin
          }
        }
      }
    }
  }
}
```


## parameters

| Parameter                          | Description                                                                                                                                                                                                                                          | Type                                                                                                                                          | Default           | Example                                                                                                                                                                                                                                                                                                                                                  |
|------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `rest_api_id`                      | aws_api_gateway_rest_api의 ID, 주로 변수로 사용.                                                                                                                                                                                                             | string                                                                                                                                        | -                 | `var.rest_api_id`                                                                                                                                                                                                                                                                                                                                        |
| `parent_id`                        | aws_api_gateway_resource의 부모 resource의 ID, 주로 변수로 사용.                                                                                                                                                                                                | string                                                                                                                                        | -                 | `var.parent_id`                                                                                                                                                                                                                                                                                                                                          |
| `path_part`                        | aws_api_gateway_resource의 path_part, "users/favorite/brands 리소스를 생성한다면, "brands"                                                                                                                                                                     | string                                                                                                                                        | -                 | `"users"`                                                                                                                                                                                                                                                                                                                                                |
| `method_values`                    | method별로 aws_api_gateway_method, aws_api_gateway_method_response, aws_api_gateway_integration, aws_api_gateway_interation_response의 attribute를 나타내는 map, 키 값으로 aws_api_gateway_method의 HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)를 갖는다 | any                                                                                                                                           | `{}`              | `{GET = { ... }, POST = { ... }}`                                                                                                                                                                                                                                                                                                                        |
| `common_values`                    | method_values 에서 모든 method에 공통으로 정의하는 aws_api_gateway_method, aws_api_gateway_method_response, aws_api_gateway_integration, aws_api_gateway_interation_response의 attribute를 나타내는 map                                                                 | any                                                                                                                                           | `{}`              | `{ response_models = {...} }`                                                                                                                                                                                                                                                                                                                            |

## method_values & common_values 의 parameters

| Parameter                          | Description                                                                                                                                                      | Type                                                                                                                                          | Default                                                        | Example                                                                                                                                                                                                                                                                                                                                                  |
|------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `resource_id`                      | aws_api_gateway_resource의 ID, 주로 변수로 사용                                                                                                                          | string                                                                                                                                        | -                                                              | `var.resource_id`                                                                                                                                                                                                                                                                                                                                        |
| `api_key_required`                 | aws_api_gateway_method가 ApiKey를 필요로 하는지 여부                                                                                                                       | bool                                                                                                                                          | `false`                                                        | `true`                                                                                                                                                                                                                                                                                                                                                   |
| `authorization`                    | aws_api_gateway_method의 authorization type (NONE, AWS_IAM, CUSTOM, COGNITO_USER_POOLS), 주로 변수로 사용                                                                | string                                                                                                                                        | `"NONE"`                                                       | `var.args.authorization.CUSTOM`                                                                                                                                                                                                                                                                                                                          |
| `authorizer_id`                    | aws_api_gateway_method가 사용하는 custom authorizer의 ID, 주로 변수로 사용                                                                                                    | string                                                                                                                                        | -                                                              | `var.args.hwahae_authorizer_id_map.default`                                                                                                                                                                                                                                                                                                              |
| `method_request_parameters`        | aws_api_gateway_method의 request parameters 정보를 나타내는 map                                                                                                          | map(string)                                                                                                                                   | -                                                              | `{"method.request.querystring.userId" = "false"}`                                                                                                                                                                                                                                                                                                        |
| `method_response_map`              | aws_api_gateway_method_response의 status_code별 response parameters, response_models 정보를 나타내는 map, status = 200 일 때의 응답이 들어가는 경우가 디폴트이므로, 아예 없는 경우에는 {}를 넣어줘야 합니다. | map(object({response_parameters = optional(map(string)) response_models = optional(map(string))}))                                            | `"200" : {"response_parameters" : {},"response_models" : {},}` | `{ 200 = { response_parameters = { ... } } }`                                                                                                                                                                                                                                                                                                            |
| `integration_request_parameters`   | aws_api_gateway_integration의 request_paremeters 정보를 나타내는 map                                                                                                     | map(string)                                                                                                                                   | -                                                              | `{"integration.request.path.award_id" = "method.request.path.award_id"}`                                                                                                                                                                                                                                                                                 |
| `integration_connection_type`      | aws_api_gateway_integration의 connection_type (INTERNET, VPC_LINK)                                                                                                | string                                                                                                                                        | `"INTERNET"`                                                   | `"INTERNET"`                                                                                                                                                                                                                                                                                                                                             |
| `integration_http_method`          | aws_api_gateway_integration의 HTTP method (GET, POST, PUT, DELETE, HEAD, OPTIONS, ANY)                                                                            | string                                                                                                                                        | -                                                              | `"POST"`                                                                                                                                                                                                                                                                                                                                                 |
| `integration_passthrough_behavior` | aws_api_gateway_integration의 passthrough_behavior (WHEN_NO_MATCH, WHEN_NO_TEMPLATES, NEVER)                                                                      | string                                                                                                                                        | `"WHEN_NO_MATCH"`                                              | `"WHEN_NO_MATCH"`                                                                                                                                                                                                                                                                                                                                        |
| `integration_timeout_milliseconds` | aws_api_gateway_integration의 timeout_milliseconds (50 ~ 29000)                                                                                                   | number                                                                                                                                        | `29000`                                                        | `5000`                                                                                                                                                                                                                                                                                                                                                   |
| `integration_type`                 | aws_api_gateway_integration의 type (AWS, AWS_PROXY, HTTP, HTTP_PROXY, MOCK)                                                                                       | string                                                                                                                                        | `"HTTP_PROXY"`                                                 | `"HTTP"`                                                                                                                                                                                                                                                                                                                                                 |
| `integration_uri`                  | aws_api_gateway_integration의 uri                                                                                                                                 | string                                                                                                                                        | -                                                              | `"http://$${stageVariables.HWAHAE_SERVER_API_ALB}/$${stageVariables.version}/braze/user/attribute"`                                                                                                                                                                                                                                                      |
| `integration_request_templates`    | aws_api_gateway_integration의 request_templates, 주로 변수로 사용                                                                                                        | map(string)                                                                                                                                   | -                                                              | `var.args.request_templates_status_200`, `{ "application/json" = "#set($$HwahaeLegacyRequestOverride = \"1\")\n#set($$HwahaeLegacyRequest = $$input.params('hwahae-legacy-request'))\n$$input.json(\"$$\")\n#if($$HwahaeLegacyRequest == \"\")\n  #set($$context.requestOverride.header.hwahae-legacy-request = $$HwahaeLegacyRequestOverride)\n#end" }` |
| `integration_response_map`         | aws_api_gateway_integration_response의 status_code별 response_models, response parameters, selection_pattern 정보를 나타내는 map                                          | map(object({response_models     = optional(map(string)) response_parameters = optional(map(string)) selection_pattern   = optional(string)})) | -                                                              | `{ 200 = { selection_pattern = "pattern1", response_models = { ... } } }`                                                                                                                                                                                                                                                                                |

