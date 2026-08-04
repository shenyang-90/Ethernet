#ifndef FRAME_PAYLOAD_H
#define FRAME_PAYLOAD_H

/**
 * @file frame_payload.h
 * @brief 自定义 TLM Payload，直接携带帧元数据
 */

#include <tlm>
#include "ethernet_types.h"
#include "tlm_mm.h"

namespace ethernet_tlm {

/**
 * @class frame_payload
 * @brief 携带帧元数据的 TLM generic payload
 */
class frame_payload : public tlm::tlm_generic_payload {
public:
    frame_payload()
        : tlm::tlm_generic_payload(&tlm_mm::instance())
    {
        acquire();
    }

    explicit frame_payload(const frame_meta& m)
        : tlm::tlm_generic_payload(&tlm_mm::instance())
        , meta(m)
    {
        acquire();
    }

    virtual ~frame_payload() = default;

    // 帧元数据
    frame_meta meta;

    // 帧数据（可选）
    std::vector<uint8_t> frame_data;
};

/**
 * @brief 便捷函数：创建 frame_payload
 */
inline frame_payload* create_frame_payload(const frame_meta& meta) {
    auto* trans = new frame_payload(meta);
    trans->set_data_ptr(nullptr);
    trans->set_data_length(meta.length);
    return trans;
}

/**
 * @brief 便捷函数：从 transaction 获取 frame_meta
 */
inline frame_meta* get_frame_meta_mut(tlm::tlm_generic_payload& trans) {
    auto* fp = dynamic_cast<frame_payload*>(&trans);
    return fp ? &fp->meta : nullptr;
}

inline const frame_meta* get_frame_meta(const tlm::tlm_generic_payload& trans) {
    auto* fp = dynamic_cast<const frame_payload*>(&trans);
    return fp ? &fp->meta : nullptr;
}

} // namespace ethernet_tlm

#endif // FRAME_PAYLOAD_H
