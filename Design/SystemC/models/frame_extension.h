#ifndef FRAME_EXTENSION_H
#define FRAME_EXTENSION_H

/**
 * @file frame_extension.h
 * @brief TLM 2.0 Generic Payload 扩展 — 帧元数据传输
 */

#include <tlm>
#include "ethernet_types.h"

namespace ethernet_tlm {

/**
 * @class frame_extension
 * @brief TLM generic payload 扩展，携带以太网帧元数据
 *
 * 使用方式：
 *   auto* ext = new frame_extension();
 *   ext->meta.dst_mac = ...;
 *   trans.set_extension(ext);
 */
class frame_extension : public tlm::tlm_extension<frame_extension> {
public:
    frame_extension() = default;
    explicit frame_extension(const frame_meta& m) : meta(m) {}

    // TLM extension interface
    tlm_extension_base* clone() const override {
        return new frame_extension(meta);
    }

    void copy_from(tlm_extension_base const& ext) override {
        meta = static_cast<const frame_extension&>(ext).meta;
    }

    // 帧元数据
    frame_meta meta;

    // 原始帧数据指针（可选，用于零拷贝）
    const uint8_t* frame_data = nullptr;
    size_t frame_data_len = 0;
};

/**
 * @class dma_extension
 * @brief DMA 事务扩展，携带通道/描述符信息
 */
class dma_extension : public tlm::tlm_extension<dma_extension> {
public:
    dma_extension() = default;

    tlm_extension_base* clone() const override {
        auto* ext = new dma_extension();
        ext->channel_id = channel_id;
        ext->mac_id = mac_id;
        ext->avtp_stream_id = avtp_stream_id;
        ext->desc_addr = desc_addr;
        ext->is_write_back = is_write_back;
        return ext;
    }

    void copy_from(tlm_extension_base const& ext) override {
        const auto& other = static_cast<const dma_extension&>(ext);
        channel_id = other.channel_id;
        mac_id = other.mac_id;
        avtp_stream_id = other.avtp_stream_id;
        desc_addr = other.desc_addr;
        is_write_back = other.is_write_back;
    }

    int      channel_id = -1;
    int      mac_id = -1;
    uint16_t avtp_stream_id = 0;
    uint64_t desc_addr = 0;
    bool     is_write_back = false;
};

/**
 * @brief 便捷函数：从 transaction 中提取 frame_meta
 */
inline const frame_meta* get_frame_meta(const tlm::tlm_generic_payload& trans) {
    frame_extension* ext = nullptr;
    trans.get_extension(ext);
    return ext ? &ext->meta : nullptr;
}

/**
 * @brief 便捷函数：从 transaction 中提取 frame_meta（可修改）
 */
inline frame_meta* get_frame_meta_mut(tlm::tlm_generic_payload& trans) {
    frame_extension* ext = nullptr;
    trans.get_extension(ext);
    return ext ? &ext->meta : nullptr;
}

} // namespace ethernet_tlm

#endif // FRAME_EXTENSION_H
